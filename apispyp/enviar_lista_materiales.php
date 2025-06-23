<?php
set_exception_handler(function($e) {
    http_response_code(500);
    header('Content-Type: application/json; charset=UTF-8');
    error_log('EXCEPCIÓN FATAL: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => true,
        'message' => 'Error interno del servidor. Intenta más tarde.'
    ]);
    exit;
});
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    http_response_code(500);
    header('Content-Type: application/json; charset=UTF-8');
    error_log("PHP ERROR ($errno): $errstr en $errfile:$errline");
    echo json_encode([
        'success' => false,
        'error' => true,
        'message' => 'Error interno del servidor. Intenta más tarde.'
    ]);
    exit;
});

header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require 'connection.php';

$response = [
    'success' => false,
    'message' => '',
    'errors'  => []
];

// Solo POST (recibiendo JSON)
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response['message'] = 'Método no permitido';
    http_response_code(405);
    echo json_encode($response);
    exit;
}

$input = json_decode(file_get_contents("php://input"), true);

// Validar datos obligatorios
$id_servicio = isset($input['id_servicio']) ? intval($input['id_servicio']) : null;
$materiales = isset($input['materiales']) ? $input['materiales'] : [];

if (!$id_servicio) $response['errors']['id_servicio'] = 'ID de servicio requerido';
if (empty($materiales) || !is_array($materiales)) $response['errors']['materiales'] = 'Lista de materiales requerida';

if (!empty($response['errors'])) {
    $response['message'] = 'Datos incompletos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

try {
    $conn->begin_transaction();

    // Borra materiales anteriores si existen
    $conn->query("DELETE FROM materiales_servicio WHERE id_servicio = $id_servicio");

    // Inserta cada material
    $stmt = $conn->prepare("INSERT INTO materiales_servicio (id_servicio, nombre_material, precio_unitario, cantidad) VALUES (?, ?, ?, ?)");
    foreach ($materiales as $mat) {
        $nombre = $mat['nombre_material'] ?? '';
        $precio = $mat['precio_unitario'] ?? 0;
        $cantidad = $mat['cantidad'] ?? 1;
        $stmt->bind_param("isdi", $id_servicio, $nombre, $precio, $cantidad);
        $stmt->execute();
    }
    $stmt->close();

    // Cambia el estado del servicio a 'pendiente_materiales'
    $conn->query("UPDATE servicios SET estado = 'pendiente_materiales' WHERE id = $id_servicio");

    $conn->commit();
    $response['success'] = true;
    $response['message'] = 'Lista enviada y estado actualizado';
    http_response_code(200);
} catch (Exception $e) {
    $conn->rollback();
    error_log('ERROR al guardar materiales: ' . $e->getMessage());
    $response['message'] = 'No se pudo guardar la lista de materiales. Intenta de nuevo.';
    http_response_code(500);
} finally {
    $conn->close();
}

echo json_encode($response);
?>