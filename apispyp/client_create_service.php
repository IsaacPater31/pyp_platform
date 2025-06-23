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
$id_cliente      = isset($input['id_cliente'])      ? intval($input['id_cliente'])        : null;
$id_especialidad = isset($input['id_especialidad']) ? intval($input['id_especialidad'])   : null;
$descripcion     = isset($input['descripcion'])     ? trim($input['descripcion'])         : '';
$precio_cliente  = isset($input['precio_cliente'])  ? floatval($input['precio_cliente'])  : null;
$fecha           = isset($input['fecha'])           ? trim($input['fecha'])               : '';
$franja_horaria  = isset($input['franja_horaria'])  ? trim($input['franja_horaria'])      : '';

if (!$id_cliente)      $response['errors']['id_cliente']      = 'ID de cliente requerido';
if (!$id_especialidad) $response['errors']['id_especialidad'] = 'Especialidad requerida';
if (!$descripcion)     $response['errors']['descripcion']     = 'Descripción requerida';
if (!$precio_cliente)  $response['errors']['precio_cliente']  = 'Precio requerido';
if (!$fecha)           $response['errors']['fecha']           = 'Fecha requerida';
if (!$franja_horaria)  $response['errors']['franja_horaria']  = 'Franja horaria requerida';

if (!empty($response['errors'])) {
    $response['message'] = 'Datos incompletos';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Buscar la ubicación geométrica del cliente
$stmt = $conn->prepare("SELECT ST_AsText(ubicacion) as ubicacion FROM clientes WHERE id = ?");
$stmt->bind_param("i", $id_cliente);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    $ubicacion = $row['ubicacion']; // Ejemplo: POINT(-74.08083 4.60971)
} else {
    $response['message'] = 'Cliente no encontrado';
    http_response_code(404);
    echo json_encode($response);
    exit;
}
$stmt->close();

$estado = 'esperando_profesional';

try {
    // Guardar la ubicación POINT en el campo direccion del servicio
    $stmt = $conn->prepare("INSERT INTO servicios (
        id_cliente, id_especialidad, descripcion, precio_cliente, fecha, franja_horaria, direccion, estado
    ) VALUES (?, ?, ?, ?, ?, ?, ST_GeomFromText(?), ?)");
    $stmt->bind_param(
        "iisdssss",
        $id_cliente,
        $id_especialidad,
        $descripcion,
        $precio_cliente,
        $fecha,
        $franja_horaria,
        $ubicacion,
        $estado
    );

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = 'Servicio creado correctamente';
        http_response_code(201);
    } else {
        throw new Exception("Error al insertar: " . $stmt->error);
    }
} catch (Exception $e) {
    error_log('ERROR al crear servicio: ' . $e->getMessage());
    $response['message'] = 'No se pudo crear el servicio. Intenta de nuevo.';
    http_response_code(500);
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
