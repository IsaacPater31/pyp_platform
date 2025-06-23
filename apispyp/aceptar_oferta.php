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

if (!$id_servicio) $response['errors']['id_servicio'] = 'ID de servicio requerido';
if (!$id_profesional) $response['errors']['id_profesional'] = 'ID de profesional requerido';

if (!empty($response['errors'])) {
    $response['message'] = 'Datos incompletos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

try {
    // Obtener el precio propuesto por el cliente
    $queryPrecio = "SELECT precio_cliente FROM servicios WHERE id = ?";
    $stmtPrecio = $conn->prepare($queryPrecio);
    $stmtPrecio->bind_param("i", $id_servicio);
    $stmtPrecio->execute();
    $stmtPrecio->bind_result($precio_cliente);
    if (!$stmtPrecio->fetch()) {
        throw new Exception('Servicio no encontrado');
    }
    $stmtPrecio->close();

    // Insertar la oferta del profesional con el mismo precio y estado 'pendiente'
    $queryOferta = "INSERT INTO ofertas_servicio (id_servicio, id_profesional, precio_ofertado, estado) VALUES (?, ?, ?, 'pendiente')";
    $stmtOferta = $conn->prepare($queryOferta);
    $stmtOferta->bind_param("iid", $id_servicio, $id_profesional, $precio_cliente);
    $stmtOferta->execute();
    $stmtOferta->close();

    // Dejar el estado del servicio en 'esperando_profesional'
    $queryServicio = "UPDATE servicios SET estado = 'esperando_profesional' WHERE id = ?";
    $stmtServicio = $conn->prepare($queryServicio);
    $stmtServicio->bind_param("i", $id_servicio);
    $stmtServicio->execute();
    $stmtServicio->close();

    $response['success'] = true;
    $response['message'] = 'Oferta enviada correctamente, a la espera de la aceptación del cliente.';
    http_response_code(200);
} catch (Exception $e) {
    error_log('ERROR al aceptar la oferta: ' . $e->getMessage());
    $response['message'] = 'No se pudo aceptar la oferta. Intenta de nuevo.';
    http_response_code(500);
} finally {
    $conn->close();
}

echo json_encode($response);
?>