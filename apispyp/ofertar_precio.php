<?php
// --- MANEJO DE ERRORES GLOBAL JSON Y LOGS ---
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
$id_profesional = isset($input['id_profesional']) ? intval($input['id_profesional']) : null;
$precio_ofertado = isset($input['precio_ofertado']) ? floatval($input['precio_ofertado']) : null;

if (!$id_servicio) $response['errors']['id_servicio'] = 'ID de servicio requerido';
if (!$id_profesional) $response['errors']['id_profesional'] = 'ID de profesional requerido';
if (!$precio_ofertado) $response['errors']['precio_ofertado'] = 'Precio ofertado requerido';

if (!empty($response['errors'])) {
    $response['message'] = 'Datos incompletos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

try {
    // Insertar la oferta
    $query = "INSERT INTO ofertas_servicio (id_servicio, id_profesional, precio_ofertado, estado) VALUES (?, ?, ?, 'pendiente')";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("iid", $id_servicio, $id_profesional, $precio_ofertado);
    $stmt->execute();

    $response['success'] = true;
    $response['message'] = 'Oferta enviada con éxito';
    http_response_code(200);
} catch (Exception $e) {
    error_log('ERROR al ofertar el precio: ' . $e->getMessage());
    $response['message'] = 'No se pudo enviar la oferta. Intenta de nuevo.';
    http_response_code(500);
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
