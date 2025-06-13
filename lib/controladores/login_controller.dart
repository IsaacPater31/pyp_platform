import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole; // Puede ser 'cliente' o 'profesional'
  bool isLoading = false;
  String? apiResponseMessage;

  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  // Realizar la solicitud de login
  Future<Map<String, dynamic>> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      return {
        'success': false,
        'message': 'Por favor, ingresa el usuario y la contraseña.'
      };
    }

    isLoading = true;

    // Dependiendo del rol seleccionado, usamos la API correspondiente
    String apiUrl;
    if (selectedRole == 'cliente') {
      apiUrl = '$baseUrl/login_client.php'; // URL de la API para cliente
    } else if (selectedRole == 'profesional') {
      apiUrl = '$baseUrl/login_professional.php'; // URL de la API para profesional
    } else {
      return {
        'success': false,
        'message': 'Por favor, selecciona un rol.'
      };
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        // Si la respuesta es exitosa
        return {'success': true, 'message': 'Inicio de sesión exitoso'};
      } else {
        // Si la respuesta tiene un error
        apiResponseMessage = jsonResponse['message'];
        return {'success': false, 'message': apiResponseMessage};
      }
    } catch (e) {
      apiResponseMessage = 'Error de conexión: ${e.toString()}';
      return {'success': false, 'message': apiResponseMessage};
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
