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

// Manejo de error de conexión
if (isset($GLOBALS['DB_CONNECTION_ERROR'])) {
    http_response_code(500);
    echo json_encode([
        'error' => true,
        'message' => $GLOBALS['DB_CONNECTION_ERROR']
    ]);
    exit;
}

// Leer y sanitizar la entrada
$input = json_decode(file_get_contents("php://input"), true);

$username = isset($input['username']) ? trim($input['username']) : null;
$email = isset($input['email']) ? trim($input['email']) : null;
$numero_documento = isset($input['numero_documento']) ? trim($input['numero_documento']) : null;

// Debe enviar al menos uno
if (!$username && !$email && !$numero_documento) {
    http_response_code(400);
    echo json_encode([
        'error' => true,
        'message' => 'Debe proporcionar al menos un nombre de usuario, un correo electrónico o un número de documento.'
    ]);
    exit;
}

$username_in_use = false;
$email_in_use = false;
$document_in_use = false;

// Verificar si el nombre de usuario ya existe
if ($username) {
    $stmt = $conn->prepare("SELECT id FROM clientes WHERE username = ?");
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['error' => true, 'message' => 'Error al verificar el nombre de usuario']);
        exit;
    }
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $stmt->store_result();
    $username_in_use = $stmt->num_rows > 0;
    $stmt->close();
}

// Verificar si el correo ya existe
if ($email) {
    $stmt = $conn->prepare("SELECT id FROM clientes WHERE email = ?");
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['error' => true, 'message' => 'Error al verificar el correo electrónico']);
        exit;
    }
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();
    $email_in_use = $stmt->num_rows > 0;
    $stmt->close();
}

// Verificar si el número de documento ya existe
if ($numero_documento) {
    $stmt = $conn->prepare("SELECT id FROM clientes WHERE numero_documento = ?");
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['error' => true, 'message' => 'Error al verificar el número de documento']);
        exit;
    }
    $stmt->bind_param("s", $numero_documento);
    $stmt->execute();
    $stmt->store_result();
    $document_in_use = $stmt->num_rows > 0;
    $stmt->close();
}

// Crear mensaje final y determinar si es un error
$messages = [];
$is_error = false;
if ($username_in_use) {
    $messages[] = 'El nombre de usuario ya está en uso.';
    $is_error = true;
}
if ($email_in_use) {
    $messages[] = 'El correo electrónico ya está en uso.';
    $is_error = true;
}
if ($document_in_use) {
    $messages[] = 'El número de documento ya está en uso.';
    $is_error = true;
}
if (!$is_error) {
    $messages[] = 'Disponible para registro.';
}

// Respuesta
echo json_encode([
    'error' => $is_error,
    'message' => implode(" ", $messages)
]);

$conn->close();
?>
