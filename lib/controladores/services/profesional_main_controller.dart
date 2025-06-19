import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pyp_platform/models/profesional_model.dart';

class ProfessionalMainController {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://api.local/apispyp';

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
}
