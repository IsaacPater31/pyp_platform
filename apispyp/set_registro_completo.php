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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response['message'] = 'Método no permitido';
    http_response_code(405);
    echo json_encode($response);
    exit;
}

// Validar datos enviados
if (empty($_POST['id_profesional'])) {
    $response['errors']['id_profesional'] = 'ID de profesional requerido';
    $response['message'] = 'Error en los datos enviados';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

$id_profesional = intval($_POST['id_profesional']);

try {
    $stmt = $conn->prepare("UPDATE profesionales SET estado_registro = 'completo' WHERE id = ?");
    $stmt->bind_param('i', $id_profesional);

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = 'Registro marcado como completo exitosamente';
        http_response_code(200);
    } else {
        throw new Exception("Error al actualizar la base de datos: " . $stmt->error);
    }
} catch (Exception $e) {
    error_log('ERROR al marcar registro como completo: ' . $e->getMessage());
    $response['message'] = 'Error interno del servidor. Intenta más tarde.';
    http_response_code(500);
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
