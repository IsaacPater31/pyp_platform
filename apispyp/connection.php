<?php
// Permitir acceso desde cualquier origen (para desarrollo)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Responder a solicitudes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuración de la conexión
$host = "localhost";
$user = "root";
$pass = "";
$dbname = "pypplatform";

// Establecer conexión
$conn = new mysqli($host, $user, $pass, $dbname);

// Manejar errores de conexión sin generar output
if ($conn->connect_error) {
    // Registrar el error sin mostrar detalles sensibles
    error_log("Error de conexión a la BD: " . $conn->connect_error);
    $GLOBALS['DB_CONNECTION_ERROR'] = "Error al conectar con la base de datos";
    $conn = null; // Asegurar que no queda conexión abierta
}

// NOTA: Se ha eliminado el echo que confirmaba la conexión exitosa
// para evitar múltiples respuestas JSON
?>