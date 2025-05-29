<?php
// Limpiar cualquier buffer de salida previo
while (ob_get_level() > 0) {
    ob_end_clean();
}

// Configurar headers CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Incluir conexión a la base de datos
require_once "connection.php";

// Función para enviar respuestas JSON consistentes
function sendJsonResponse($status, $message, $additionalData = []) {
    $response = array_merge([
        'status' => $status,
        'message' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ], $additionalData);
    
    // Limpiar buffer nuevamente por si acaso
    if (ob_get_length() > 0) {
        ob_clean();
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

// Verificar si hubo error de conexión con la BD
if (isset($GLOBALS['DB_CONNECTION_ERROR'])) {
    sendJsonResponse("error", $GLOBALS['DB_CONNECTION_ERROR']);
}

// Verificar método POST
if ($_SERVER["REQUEST_METHOD"] != "POST") {
    sendJsonResponse("error", "Método no permitido. Usa POST");
}

// Leer datos del body
$input = json_decode(file_get_contents("php://input"), true) ?? $_POST;

// Validar campos obligatorios
$requiredFields = ['username', 'full_name', 'email', 'phone', 'password', 'departamento', 'ciudad', 'postal_code', 'direccion'];
$missingFields = [];
foreach ($requiredFields as $field) {
    if (empty($input[$field])) {
        $missingFields[] = $field;
    }
}

if (!empty($missingFields)) {
    sendJsonResponse("error", "Faltan campos obligatorios: " . implode(', ', $missingFields));
}

// Validar formato de email
if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
    sendJsonResponse("error", "El formato del correo electrónico no es válido");
}

// Escapar datos para evitar inyecciones SQL
$username = $conn->real_escape_string($input['username']);
$full_name = $conn->real_escape_string($input['full_name']);
$email = $conn->real_escape_string($input['email']);
$phone = $conn->real_escape_string($input['phone']);
$departamento = $conn->real_escape_string($input['departamento']);
$ciudad = $conn->real_escape_string($input['ciudad']);
$postal_code = $conn->real_escape_string($input['postal_code']);
$direccion = $conn->real_escape_string($input['direccion']);

// Verificar si el usuario o email ya existen
$checkQuery = $conn->prepare("SELECT username, email FROM clientes WHERE username = ? OR email = ?");
$checkQuery->bind_param("ss", $username, $email);
$checkQuery->execute();
$checkResult = $checkQuery->get_result();

if ($checkResult->num_rows > 0) {
    $existing = $checkResult->fetch_assoc();
    $errors = [];
    
    if (strcasecmp($existing['username'], $username) === 0) {
        $errors[] = "El nombre de usuario ya está en uso";
    }
    if (strcasecmp($existing['email'], $email) === 0) {
        $errors[] = "El correo electrónico ya está registrado";
    }
    
    sendJsonResponse("error", implode(" y ", $errors));
}

// Hashear la contraseña
$hash_password = password_hash($input['password'], PASSWORD_DEFAULT);

// Preparar inserción
$stmt = $conn->prepare("INSERT INTO clientes (username, full_name, email, phone, password, departamento, ciudad, postal_code, direccion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    sendJsonResponse("error", "Error al preparar la consulta: " . $conn->error);
}

$stmt->bind_param("sssssssss", $username, $full_name, $email, $phone, $hash_password, $departamento, $ciudad, $postal_code, $direccion);

// Ejecutar y responder
if ($stmt->execute()) {
    sendJsonResponse("success", "Cliente registrado correctamente", [
        'client_id' => $stmt->insert_id,
        'username' => $username,
        'email' => $email
    ]);
} else {
    sendJsonResponse("error", "Error al registrar: " . $stmt->error);
}

?>