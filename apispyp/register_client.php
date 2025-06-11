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
$errors = [];
$requiredFields = [
    'username', 'email', 'password', 'latitud', 'longitud',
    'tipo_documento', 'numero_documento'
];

foreach ($requiredFields as $field) {
    if (empty($data[$field])) {
        $errors[$field] = "Campo requerido";
    }
}

// Validar tipo_documento
$tiposValidos = ['Cédula de Ciudadanía', 'Cédula de Extranjería'];
if (!in_array($data['tipo_documento'] ?? '', $tiposValidos)) {
    $errors['tipo_documento'] = 'Tipo de documento inválido';
}

if (!filter_var($data['email'] ?? '', FILTER_VALIDATE_EMAIL)) {
    $errors['email'] = 'Email inválido';
}

if (strlen($data['password'] ?? '') < 6) {
    $errors['password'] = 'Mínimo 6 caracteres';
}

if (!empty($errors)) {
    $response['errors'] = $errors;
    $response['message'] = 'Error en los datos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

try {
    // Verificar si username, email o numero_documento ya existen
    $checkQuery = "SELECT id FROM clientes WHERE username = ? OR email = ? OR numero_documento = ?";
    $stmt = $conn->prepare($checkQuery);

    $username = $data['username'] ?? '';
    $email = $data['email'] ?? '';
    $numero_documento = $data['numero_documento'] ?? '';

    $stmt->bind_param("sss", $username, $email, $numero_documento);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $response['message'] = 'El usuario, email o número de documento ya existen';
        http_response_code(409);
        echo json_encode($response);
        exit;
    }
    $stmt->close();

    $passwordHash = password_hash($data['password'], PASSWORD_DEFAULT);

    $fechaNacimiento = null;
    if (!empty($data['fecha_nacimiento'])) {
        $fechaNacimiento = date('Y-m-d', strtotime($data['fecha_nacimiento']));
    }

    $insertQuery = "INSERT INTO clientes (
        tipo_documento, numero_documento, username, full_name, email, phone, password, fecha_nacimiento,
        departamento, ciudad, postal_code, detalle_direccion, ubicacion
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ST_GeomFromText(?))";

    $point = "POINT(" . floatval($data['latitud']) . " " . floatval($data['longitud']) . ")";

    $full_name = $data['full_name'] ?? '';
    $phone = $data['phone'] ?? '';
    $departamento = $data['departamento'] ?? '';
    $ciudad = $data['ciudad'] ?? '';
    $postal_code = $data['postal_code'] ?? '';
    $detalle_direccion = $data['detalle_direccion'] ?? '';

    $fechaNacimientoForBind = $fechaNacimiento ?? null;

    $stmt = $conn->prepare($insertQuery);

    $stmt->bind_param("sssssssssssss",
        $data['tipo_documento'],
        $data['numero_documento'],
        $data['username'],
        $full_name,
        $data['email'],
        $phone,
        $passwordHash,
        $fechaNacimientoForBind,
        $departamento,
        $ciudad,
        $postal_code,
        $detalle_direccion,
        $point
    );

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = 'Registro exitoso';
        http_response_code(201);
    } else {
        throw new Exception("Error al ejecutar la consulta: " . $stmt->error);
    }
} catch (Exception $e) {
    // Solo mensaje genérico al usuario, detalles en el log
    error_log('ERROR en registro de cliente: ' . $e->getMessage());
    $response['message'] = 'Error interno del servidor. Intenta más tarde.';
    http_response_code(500);
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
