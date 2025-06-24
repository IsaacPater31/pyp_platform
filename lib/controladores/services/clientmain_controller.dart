import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pyp_platform/models/client_model.dart';

class ClientMainController {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://api.local/apispyp';

  Future<ClientModel?> obtenerDatosCliente(String username) async {
    final url = Uri.parse('$baseUrl/obtener_datos_cliente.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return ClientModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del cliente: $e');
      return null;
    }
  }

  Future<bool> crearServicio({
    required int idCliente,
    required int idEspecialidad,
    required String descripcion,
    required double precioCliente,
    required String fecha,
    required String franjaHoraria,
    String? observaciones,
  }) async {
    final url = Uri.parse('$baseUrl/client_create_service.php');
    try {
      final Map<String, dynamic> body = {
        'id_cliente': idCliente,
        'id_especialidad': idEspecialidad,
        'descripcion': descripcion,
        'precio_cliente': precioCliente,
        'fecha': fecha,
        'franja_horaria': franjaHoraria,
      };

      if (observaciones != null && observaciones.trim().isNotEmpty) {
        body['observaciones'] = observaciones;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al crear servicio: $e');
      return false;
    }
  }

  // NUEVO: Obtener ofertas de los servicios del cliente
  Future<List<Map<String, dynamic>>> obtenerOfertasCliente(int idCliente) async {
    final url = Uri.parse('$baseUrl/ofertas_cliente.php?id_cliente=$idCliente');
    final archivosUrl = dotenv.env['ARCHIVOS_URL'] ?? '';
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List ofertas = data['data'];
        return ofertas.map<Map<String, dynamic>>((oferta) {
          final foto = oferta['foto_perfil_profesional'];
          oferta['foto_perfil_url'] = (foto != null && foto.toString().isNotEmpty)
              ? '$archivosUrl/$foto'
              : null;
          return oferta as Map<String, dynamic>;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener ofertas del cliente: $e');
      return [];
    }
  }

  Future<bool> aceptarOferta(int idOferta) async {
    final url = Uri.parse('$baseUrl/aceptar_ofertadeprofesional.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_oferta': idOferta}),
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al aceptar oferta: $e');
      return false;
    }
  }

  Future<bool> rechazarOferta(int idOferta) async {
    final url = Uri.parse('$baseUrl/rechazar_oferta.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_oferta': idOferta}),
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al rechazar oferta: $e');
      return false;
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

  Future<bool> confirmarMaterialesCliente(int idServicio, List<Map<String, dynamic>> materiales) async {
    final url = Uri.parse('$baseUrl/cliente_confirmar_materiales.php');
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
      return data['success'] == true;
    } catch (e) {
      print('Error al confirmar materiales: $e');
      return false;
    }
  }

  Future<bool> reportarProfesional(int idProfesional) async {
    final url = Uri.parse('$baseUrl/reportar_profesional.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_profesional': idProfesional}),
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al reportar profesional: $e');
      return false;
    }
  }

  Future<bool> ofertarPrecioCliente(int idServicio, double nuevoPrecio) async {
    final url = Uri.parse('$baseUrl/cliente_ofertar_precio.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_servicio': idServicio, 'nuevo_precio': nuevoPrecio}),
      );
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al ofertar precio: $e');
      return false;
    }
  }
  
}
