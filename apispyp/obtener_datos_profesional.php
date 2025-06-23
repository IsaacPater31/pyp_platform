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

// obtener_datos_profesional.php

require_once 'connection.php';
header("Content-Type: application/json; charset=UTF-8");

$input = json_decode(file_get_contents("php://input"), true);
$username = isset($input['username']) ? trim($input['username']) : null;

if (!$username) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Usuario requerido']);
    exit;
}

$stmt = $conn->prepare("
    SELECT id, tipo_documento, numero_documento, username, full_name, email, phone,
           fecha_nacimiento, departamento, ciudad, postal_code,
           valoracion_promedio, servicios_adquiridos, fecha_creacion, estado_suscripcion,
           estado_validacion, estado_registro, foto_perfil, certificado_antecedentes,
           foto_documento_frontal, foto_documento_reverso, certificados_especialidades,
           certificacion_verificada
    FROM profesionales
    WHERE username = ?
");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    // Obtener las especialidades de este profesional
    $stmtEsp = $conn->prepare("
        SELECT e.nombre
        FROM profesional_especialidad pe
        JOIN especialidades e ON pe.id_especialidad = e.id
        WHERE pe.id_profesional = ?
    ");
    $stmtEsp->bind_param("i", $row['id']);
    $stmtEsp->execute();
    $resEsp = $stmtEsp->get_result();

    $especialidades = [];
    while ($esp = $resEsp->fetch_assoc()) {
        $especialidades[] = $esp['nombre'];
    }
    $row['especialidades'] = $especialidades;

    echo json_encode(['success' => true, 'data' => $row]);
    $stmtEsp->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Profesional no encontrado']);
}
$conn->close();
?>
