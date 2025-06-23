<?php
// --- Manejo de errores global y logs ---
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

require 'connection.php'; // Incluir archivo de conexión

$response = [
    'success' => false,
    'message' => '',
    'errors' => []
];

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response['message'] = 'Método no permitido';
    http_response_code(405);
    echo json_encode($response);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    $response['message'] = 'JSON inválido';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Validación de campos requeridos
$requiredFields = ['username', 'password'];
foreach ($requiredFields as $field) {
    if (empty($data[$field])) {
        $response['errors'][$field] = "Campo requerido";
    }
}

if (!empty($response['errors'])) {
    $response['message'] = 'Error en los datos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Verificar si el cliente existe
$username = $data['username'];
$password = $data['password'];

$query = "SELECT id, password FROM clientes WHERE username = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $username);
$stmt->execute();
$stmt->store_result();
$stmt->bind_result($id, $hashedPassword);

if ($stmt->num_rows > 0) {
    $stmt->fetch();
    if (password_verify($password, $hashedPassword)) {
        // Login exitoso
        $response['success'] = true;
        $response['message'] = 'Inicio de sesión exitoso';
        http_response_code(200);
    } else {
        $response['message'] = 'Contraseña incorrecta';
        http_response_code(401);
    }
} else {
    $response['message'] = 'Usuario no encontrado';
    http_response_code(404);
}

$stmt->close();
$conn->close();

echo json_encode($response);
?>
