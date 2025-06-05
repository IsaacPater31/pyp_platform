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

// Conexión reutilizable
require 'connection.php';

$response = [
    'success' => false,
    'message' => '',
    'errors' => []
];

// Solo POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response['message'] = 'Método no permitido';
    http_response_code(405);
    echo json_encode($response);
    exit;
}

// Tomar y decodificar el JSON
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    $response['message'] = 'JSON inválido';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Validar campos requeridos
$requiredFields = [
    'tipo_documento', 'numero_documento', 'username', 'full_name', 'password',
    'email', 'phone', 'fecha_nacimiento', 'departamento', 'ciudad', 'postal_code', 'especialidades'
];
$errors = [];
foreach ($requiredFields as $field) {
    if (!isset($data[$field]) || ($field !== 'especialidades' && trim($data[$field]) === '')) {
        $errors[$field] = "Campo requerido";
    }
}
if (empty($data['especialidades']) || !is_array($data['especialidades'])) {
    $errors['especialidades'] = 'Seleccione al menos una especialidad';
}

// Validar email
if (!empty($data['email']) && !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
    $errors['email'] = 'Email inválido';
}

// Validar password mínimo 6 caracteres
if (isset($data['password']) && strlen($data['password']) < 6) {
    $errors['password'] = 'Mínimo 6 caracteres';
}

// Validar fecha de nacimiento (mayor de 18)
if (!empty($data['fecha_nacimiento'])) {
    $fecha = strtotime($data['fecha_nacimiento']);
    $edad = (int)date('Y') - (int)date('Y', $fecha);
    if ($edad < 18) $errors['fecha_nacimiento'] = 'Debes ser mayor de 18 años';
}

if (!empty($errors)) {
    $response['errors'] = $errors;
    $response['message'] = 'Error en los datos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Validar duplicados: username, email, numero_documento
try {
    $sqlCheck = "SELECT id FROM profesionales WHERE username = ? OR email = ? OR numero_documento = ?";
    $stmt = $conn->prepare($sqlCheck);
    $stmt->bind_param("sss", $data['username'], $data['email'], $data['numero_documento']);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        $response['message'] = 'El usuario, email o documento ya existen';
        http_response_code(409);
        echo json_encode($response);
        $stmt->close();
        exit;
    }
    $stmt->close();

    // Hashear password
    $passwordHash = password_hash($data['password'], PASSWORD_DEFAULT);

    // Fecha nacimiento en formato Y-m-d
    $fechaNacimiento = null;
    if (!empty($data['fecha_nacimiento'])) {
        $fechaNacimiento = date('Y-m-d', strtotime($data['fecha_nacimiento']));
    }

    // Insertar profesional (sin foto ni docs)
    $insertQuery = "INSERT INTO profesionales (
        tipo_documento, numero_documento, username, full_name, password, email, phone,
        fecha_nacimiento, departamento, ciudad, postal_code, estado_suscripcion, estado_validacion
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'inactiva', 'pendiente')";

    $stmt = $conn->prepare($insertQuery);
    $stmt->bind_param(
        "sssssssssss",
        $data['tipo_documento'],
        $data['numero_documento'],
        $data['username'],
        $data['full_name'],
        $passwordHash,
        $data['email'],
        $data['phone'],
        $fechaNacimiento,
        $data['departamento'],
        $data['ciudad'],
        $data['postal_code']
    );

    if (!$stmt->execute()) {
        throw new Exception("Error al registrar profesional: " . $stmt->error);
    }
    $profesionalId = $stmt->insert_id;
    $stmt->close();

    // Insertar especialidades en tabla puente
    $erroresEspecialidad = [];
    foreach ($data['especialidades'] as $espId) {
        $espId = intval($espId);
        $stmt = $conn->prepare("INSERT INTO profesional_especialidad (id_profesional, id_especialidad) VALUES (?, ?)");
        $stmt->bind_param("ii", $profesionalId, $espId);
        if (!$stmt->execute()) {
            $erroresEspecialidad[] = $espId;
        }
        $stmt->close();
    }

    if (!empty($erroresEspecialidad)) {
        $response['message'] = "Profesional registrado, pero error al registrar algunas especialidades.";
        $response['errores_especialidades'] = $erroresEspecialidad;
        $response['success'] = false;
        http_response_code(207); // Multi-status
    } else {
        $response['success'] = true;
        $response['message'] = 'Registro exitoso (primer paso)';
        http_response_code(201);
    }
    $response['profesional_id'] = $profesionalId;

} catch (Exception $e) {
    error_log('ERROR en registro profesional: ' . $e->getMessage());
    $response['message'] = 'Error interno del servidor. Intenta más tarde.';
    http_response_code(500);
} finally {
    if ($conn) $conn->close();
}

echo json_encode($response);
?>
