<?php
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

$id_cliente = isset($_GET['id_cliente']) ? intval($_GET['id_cliente']) : null;

if (!$id_cliente) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'ID de cliente requerido']);
    exit;
}

// Buscar todas las ofertas de los servicios de este cliente
$sql = "
SELECT 
    o.id AS id_oferta,
    o.id_servicio,
    o.id_profesional,
    o.precio_ofertado,
    o.estado AS estado_oferta,
    o.fecha AS fecha_oferta,
    s.descripcion AS descripcion_servicio,
    s.precio_cliente,
    s.estado AS estado_servicio,
    s.fecha AS fecha_servicio,
    e.nombre AS nombre_especialidad,
    p.full_name AS nombre_profesional,
    p.email AS email_profesional,
    p.phone AS telefono_profesional,
    p.foto_perfil AS foto_perfil_profesional,
    p.certificacion_verificada AS certificacion_verificada,
    p.valoracion_promedio AS valoracion_profesional,
    p.reportes_recibidos AS reportes_profesional
FROM ofertas_servicio o
JOIN servicios s ON o.id_servicio = s.id
JOIN profesionales p ON o.id_profesional = p.id
JOIN especialidades e ON s.id_especialidad = e.id
WHERE s.id_cliente = ?
ORDER BY o.fecha DESC
";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'error' => true,
        'message' => 'Error en prepare: ' . $conn->error
    ]);
    exit;
}
$stmt->bind_param('i', $id_cliente);
$stmt->execute();
$result = $stmt->get_result();

$ofertas = [];
while ($row = $result->fetch_assoc()) {
    $ofertas[] = $row;
}

echo json_encode([
    'success' => true,
    'data' => $ofertas
]);

$stmt->close();
$conn->close();
?>