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
            // Construir el cuerpo de la solicitud
            final Map<String, dynamic> body = {
              'id_cliente': idCliente,
              'id_especialidad': idEspecialidad,
              'descripcion': descripcion,
              'precio_cliente': precioCliente,
              'fecha': fecha,
              'franja_horaria': franjaHoraria,
            };

            // Solo incluye observaciones si se proporcionó
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


  
}
