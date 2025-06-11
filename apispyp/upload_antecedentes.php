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

$errors = [];
if (empty($_POST['id_profesional'])) {
    $errors['id_profesional'] = 'ID de profesional requerido';
}
if (!isset($_FILES['antecedente'])) {
    $errors['antecedente'] = 'Archivo PDF requerido';
}
if (!empty($errors)) {
    $response['errors'] = $errors;
    $response['message'] = 'Error en los datos enviados';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

$id_profesional = intval($_POST['id_profesional']);
$pdf = $_FILES['antecedente'];

// Solo PDF permitido
$extension = strtolower(pathinfo($pdf['name'], PATHINFO_EXTENSION));
if ($extension !== 'pdf') {
    $response['errors']['antecedente'] = 'Solo se permiten archivos PDF';
    $response['message'] = 'Formato inválido. Sube un PDF.';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Carpeta de certificados antecedentes
$carpeta = $_SERVER['DOCUMENT_ROOT'] . '/pyp_platform/antecedentedes_pdf/';
if (!file_exists($carpeta)) {
    mkdir($carpeta, 0777, true);
}

// Nombre único
$nombreArchivo = 'antecedentes_' . $id_profesional . '_' . time() . '.pdf';
$rutaCompleta = $carpeta . $nombreArchivo;

if (!move_uploaded_file($pdf['tmp_name'], $rutaCompleta)) {
    $response['message'] = 'No se pudo guardar el PDF';
    http_response_code(500);
    echo json_encode($response);
    exit;
}

// Guardar nombre en la BD
try {
    $stmt = $conn->prepare("UPDATE profesionales SET certificado_antecedentes = ? WHERE id = ?");
    $stmt->bind_param('si', $nombreArchivo, $id_profesional);

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = 'Certificado de antecedentes subido correctamente';
        $response['nombreArchivo'] = $nombreArchivo;

        // URL pública del archivo
        $protocolo = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https" : "http";
        $host = $_SERVER['HTTP_HOST'];
        $rutaPublica = "/pyp_platform/antecedentedes_pdf/" . $nombreArchivo;
        $response['url_antecedente'] = $protocolo . "://" . $host . $rutaPublica;

        http_response_code(200);
    } else {
        throw new Exception("Error al actualizar la base de datos: " . $stmt->error);
    }
} catch (Exception $e) {
    error_log('ERROR en subida de antecedentes profesional: ' . $e->getMessage());
    $response['message'] = 'Error interno del servidor. Intenta más tarde.';
    http_response_code(500);
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
