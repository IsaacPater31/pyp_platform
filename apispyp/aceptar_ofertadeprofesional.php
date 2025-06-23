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

require_once 'connection.php';
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
    exit;
}

$input = json_decode(file_get_contents("php://input"), true);
$id_oferta = isset($input['id_oferta']) ? intval($input['id_oferta']) : null;

if (!$id_oferta) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'ID de oferta requerido']);
    exit;
}

// 1. Obtener datos de la oferta
$stmt = $conn->prepare("SELECT id_servicio, id_profesional, precio_ofertado FROM ofertas_servicio WHERE id = ?");
$stmt->bind_param('i', $id_oferta);
$stmt->execute();
$stmt->bind_result($id_servicio, $id_profesional, $precio_ofertado);
if (!$stmt->fetch()) {
    http_response_code(404);
    echo json_encode(['success' => false, 'message' => 'Oferta no encontrada']);
    exit;
}
$stmt->close();

// 2. Aceptar la oferta seleccionada
$stmt = $conn->prepare("UPDATE ofertas_servicio SET estado = 'aceptada' WHERE id = ?");
$stmt->bind_param('i', $id_oferta);
$stmt->execute();
$stmt->close();

// 3. Rechazar las demás ofertas de ese servicio
$stmt = $conn->prepare("UPDATE ofertas_servicio SET estado = 'rechazada' WHERE id_servicio = ? AND id != ?");
$stmt->bind_param('ii', $id_servicio, $id_oferta);
$stmt->execute();
$stmt->close();

// 4. Actualizar el servicio
$stmt = $conn->prepare("UPDATE servicios SET id_profesional = ?, precio_acordado = ?, estado = 'profesional_asignado' WHERE id = ?");
$stmt->bind_param('idi', $id_profesional, $precio_ofertado, $id_servicio);
$ok = $stmt->execute();
$stmt->close();

$conn->close();

echo json_encode(['success' => $ok]);
?>