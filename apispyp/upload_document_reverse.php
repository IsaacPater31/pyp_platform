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
if (!isset($_FILES['foto'])) {
    $errors['foto'] = 'Archivo de foto requerido';
}
if (!empty($errors)) {
    $response['errors'] = $errors;
    $response['message'] = 'Error en los datos enviados';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

$id_profesional = intval($_POST['id_profesional']);
$foto = $_FILES['foto'];
$allowed = ['jpg', 'jpeg', 'png', 'webp'];
$extension = strtolower(pathinfo($foto['name'], PATHINFO_EXTENSION));

if (!in_array($extension, $allowed)) {
    $response['errors']['foto'] = 'Tipo de archivo no permitido';
    $response['message'] = 'Formato de imagen inválido (solo jpg, jpeg, png, webp)';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

// Carpeta para las fotos reversas
$carpeta = $_SERVER['DOCUMENT_ROOT'] . '/pyp_platform/reverse_documents/';
if (!file_exists($carpeta)) {
    mkdir($carpeta, 0777, true);
}

// Nombre único
$nombreArchivo = 'reverse_' . $id_profesional . '_' . time() . '.' . $extension;
$rutaCompleta = $carpeta . $nombreArchivo;

if (!move_uploaded_file($foto['tmp_name'], $rutaCompleta)) {
    $response['message'] = 'No se pudo guardar la imagen';
    http_response_code(500);
    echo json_encode($response);
    exit;
}

// Guardar nombre del archivo en la BD
try {
    $stmt = $conn->prepare("UPDATE profesionales SET foto_documento_reverso = ? WHERE id = ?");
    $stmt->bind_param('si', $nombreArchivo, $id_profesional);

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = 'Reverso del documento subido correctamente';
        $response['nombreArchivo'] = $nombreArchivo;

        // URL pública de la imagen
        $protocolo = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https" : "http";
        $host = $_SERVER['HTTP_HOST'];
        $rutaPublica = "/pyp_platform/reverse_documents/" . $nombreArchivo;
        $response['url_foto'] = $protocolo . "://" . $host . $rutaPublica;

        http_response_code(200);
    } else {
        throw new Exception("Error al actualizar la base de datos: " . $stmt->error);
    }
} catch (Exception $e) {
    error_log('ERROR en subida reverso documento profesional: ' . $e->getMessage());
    $response['message'] = 'Error interno del servidor. Intenta más tarde.';
    http_response_code(500);
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}

echo json_encode($response);
?>
