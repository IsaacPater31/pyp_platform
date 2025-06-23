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

require_once 'connection.php';
header("Content-Type: application/json; charset=UTF-8");

$input = json_decode(file_get_contents("php://input"), true);
$username = isset($input['username']) ? trim($input['username']) : null;
$rol = isset($input['rol']) ? strtolower(trim($input['rol'])) : null;

if (!$username || !$rol) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Username y rol requeridos']);
    exit;
}

// Validar el rol permitido para evitar inyección SQL
if ($rol !== 'cliente' && $rol !== 'profesional') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Rol inválido']);
    exit;
}

$tabla = $rol === 'profesional' ? 'profesionales' : 'clientes';

$query = "SELECT id FROM $tabla WHERE username = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    echo json_encode(['success' => true, 'id' => $row['id']]);
} else {
    echo json_encode(['success' => false, 'message' => ucfirst($rol) . ' no encontrado']);
}
$conn->close();
