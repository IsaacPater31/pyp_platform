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

$input = json_decode(file_get_contents("php://input"), true);
$id_profesional = isset($input['id_profesional']) ? intval($input['id_profesional']) : (isset($_GET['id_profesional']) ? intval($_GET['id_profesional']) : null);

// Verificación y log explícito del id recibido
if (!$id_profesional) {
    error_log("API servicios_profesional.php - ID de profesional NO enviado o inválido");
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'ID de profesional requerido']);
    exit;
}
error_log("API servicios_profesional.php - ID PROFESIONAL RECIBIDO: $id_profesional");

// Mostrar servicios de la especialidad del profesional, que NO estén finalizados ni impagos,
// y que estén sin profesional asignado o asignados a este profesional.
$sql = "
SELECT 
    s.*,
    ST_X(s.direccion) AS direccion_lat,
    ST_Y(s.direccion) AS direccion_lng,
    e.nombre AS nombre_especialidad,
    c.full_name AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    c.phone AS telefono_cliente,
    c.reportes_recibidos AS reportes_cliente,
    (
        SELECT COUNT(*) 
        FROM ofertas_servicio o 
        WHERE o.id_servicio = s.id AND o.id_profesional = ?
    ) AS ya_oferto
FROM servicios s
JOIN especialidades e ON s.id_especialidad = e.id
JOIN clientes c ON s.id_cliente = c.id
WHERE 
    -- Solo servicios de la especialidad del profesional
    EXISTS (
        SELECT 1 
        FROM profesional_especialidad pe 
        WHERE pe.id_profesional = ? 
        AND pe.id_especialidad = s.id_especialidad
    )
    -- Solo si no están finalizados ni impagos
    AND s.estado NOT IN ('finalizado', 'impago')
    -- Solo si no tienen profesional asignado o el asignado es el actual
    AND (s.id_profesional IS NULL OR s.id_profesional = ?)
    -- No mostrar servicios rechazados por este profesional
    AND NOT EXISTS (
        SELECT 1 FROM ofertas_servicio o
        WHERE o.id_servicio = s.id
        AND o.id_profesional = ?
        AND o.estado = 'rechazada'
    )
    -- Cliente no baneado
    AND c.baneado = 'no'
ORDER BY 
    FIELD(s.estado, 'esperando_profesional', 'negociando', 'profesional_asignado', 'pendiente_materiales', 'en_curso') ASC, 
    s.fecha_creacion DESC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param('iiii', $id_profesional, $id_profesional, $id_profesional, $id_profesional);
$stmt->execute();
$result = $stmt->get_result();

$servicios = [];
while ($row = $result->fetch_assoc()) {
    unset($row['direccion']); // Quitamos el binario, ya tienes lat/lng por separado
    $servicios[] = $row;
}

echo json_encode([
    'success' => true,
    'data' => $servicios
]);

$stmt->close();
$conn->close();
?>