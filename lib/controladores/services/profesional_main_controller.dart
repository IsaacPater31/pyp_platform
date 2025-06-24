import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pyp_platform/models/profesional_model.dart';
import 'package:pyp_platform/models/servicio_model.dart'; // <- Crea este modelo (te muestro abajo)

class ProfessionalMainController {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://api.local/apispyp';

  // Para obtener los datos del profesional
  Future<ProfesionalModel?> obtenerDatosProfesional(String username) async {
    final url = Uri.parse('$baseUrl/obtener_datos_profesional.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return ProfesionalModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del profesional: $e');
      return null;
    }
  }

  // Para obtener los servicios activos del profesional
  Future<List<ServicioModel>> obtenerServiciosActivosProfesional(int idProfesional) async {
    final url = Uri.parse('$baseUrl/servicios_profesional.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_profesional': idProfesional}),
      );

      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        List serviciosJson = data['data'];
        return serviciosJson.map((json) => ServicioModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener servicios activos: $e');
      return [];
    }
  }
  Future<Map<String, dynamic>> aceptarOferta(int idServicio, int idProfesional) async {
  final url = Uri.parse('$baseUrl/aceptar_oferta.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_servicio': idServicio, 'id_profesional': idProfesional}),
    );

    final data = json.decode(response.body);
    if (data['success'] == true) {
      return {'success': true, 'message': data['message']};
    }
    return {'success': false, 'message': data['message']};
  } catch (e) {
    print('Error al aceptar oferta: $e');
    return {'success': false, 'message': 'Error al aceptar la oferta'};
  }
}
Future<Map<String, dynamic>> ofertarPrecio(int idServicio, int idProfesional, double precioOfertado) async {
  final url = Uri.parse('$baseUrl/ofertar_precio.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_servicio': idServicio,
        'id_profesional': idProfesional,
        'precio_ofertado': precioOfertado
      }),
    );

    final data = json.decode(response.body);
    if (data['success'] == true) {
      return {'success': true, 'message': data['message']};
    }
    return {'success': false, 'message': data['message']};
  } catch (e) {
    print('Error al ofertar precio: $e');
    return {'success': false, 'message': 'Error al ofertar el precio'};
  }
}
Future<Map<String, dynamic>> rechazarOferta(int idServicio, int idProfesional) async {
  final url = Uri.parse('$baseUrl/rechazar_oferta.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_servicio': idServicio, 'id_profesional': idProfesional}),
    );

    final data = json.decode(response.body);
    if (data['success'] == true) {
      return {'success': true, 'message': data['message']};
    }
    return {'success': false, 'message': data['message']};
  } catch (e) {
    print('Error al rechazar oferta: $e');
    return {'success': false, 'message': 'Error al rechazar la oferta'};
  }
}
Future<Map<String, dynamic>> enviarListaMateriales(int idServicio, List<Map<String, dynamic>> materiales) async {
  final url = Uri.parse('$baseUrl/enviar_lista_materiales.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_servicio': idServicio,
        'materiales': materiales,
      }),
    );
    final data = json.decode(response.body);
    return data;
  } catch (e) {
    print('Error al enviar lista de materiales: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}
Future<List<Map<String, dynamic>>> obtenerMaterialesServicio(int idServicio) async {
  final url = Uri.parse('$baseUrl/materiales_servicio.php?id_servicio=$idServicio');
  try {
    final response = await http.get(url);
    final data = json.decode(response.body);
    if (data['success'] == true && data['materiales'] is List) {
      return List<Map<String, dynamic>>.from(data['materiales']);
    }
    return [];
  } catch (e) {
    print('Error al obtener materiales: $e');
    return [];
  }
}
Future<Map<String, dynamic>> validarPinServicio(int idServicio, String pin) async {
  final url = Uri.parse('$baseUrl/validar_pin_servicio.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_servicio': idServicio, 'pin': pin}),
    );
    final data = json.decode(response.body);
    return data;
  } catch (e) {
    print('Error al validar PIN: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}
Future<Map<String, dynamic>> finalizarServicio(int idServicio, {required bool pagado}) async {
  final url = Uri.parse('$baseUrl/finalizar_servicio.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_servicio': idServicio,
        'pagado': pagado ? 'si' : 'no',
      }),
    );
    final data = json.decode(response.body);
    return data;
  } catch (e) {
    print('Error al finalizar servicio: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}
Future<List<ServicioModel>> obtenerServiciosFinalizadosProfesional(int idProfesional) async {
  final url = Uri.parse('$baseUrl/servicios_finalizados_profesional.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_profesional': idProfesional}),
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['data'] != null) {
      List serviciosJson = data['data'];
      return serviciosJson.map((json) => ServicioModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('Error al obtener servicios finalizados: $e');
    return [];
  }
}
Future<Map<String, dynamic>> comentarCalificarCliente({
  required int idProfesional,
  required int idCliente,
  String comentario = '',
  int? calificacion,
}) async {
  final url = Uri.parse('$baseUrl/comentar_calificar_cliente.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_profesional': idProfesional,
        'id_cliente': idCliente,
        'comentario': comentario,
        'calificacion': calificacion,
      }),
    );
    final data = json.decode(response.body);
    return data;
  } catch (e) {
    print('Error al comentar/calificar cliente: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}
Future<Map<String, dynamic>> reportarCliente(int idCliente) async {
  final url = Uri.parse('$baseUrl/reportar_cliente.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_cliente': idCliente}),
    );
    final data = json.decode(response.body);
    return data;
  } catch (e) {
    print('Error al reportar cliente: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}
Future<Map<String, dynamic>> obtenerStatsProfesional(int idProfesional) async {
  final url = Uri.parse('$baseUrl/stats_profesional.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_profesional': idProfesional}),
    );
    final data = json.decode(response.body);
    if (data['success'] == true && data['data'] != null) {
      return data['data'];
    }
    return {};
  } catch (e) {
    print('Error al obtener estadísticas: $e');
    return {};
  }
}
}
