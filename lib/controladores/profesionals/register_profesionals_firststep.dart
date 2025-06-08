import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfessionalFirstStepController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final numeroDocumentoController = TextEditingController();
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final postalCodeController = TextEditingController();

  final tipoDocumento = ValueNotifier<String?>(null);
  final departamentoSeleccionado = ValueNotifier<String?>(null);
  final ciudadSeleccionada = ValueNotifier<String?>(null);

  final List<String> especialidadesSeleccionadas = [];

  bool isLoading = false;
  String apiMessage = '';

  // Verifica si el archivo .env está siendo cargado correctamente
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://api.local/apispyp';

  void disposeControllers() {
    numeroDocumentoController.dispose();
    usernameController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    postalCodeController.dispose();
    tipoDocumento.dispose();
    departamentoSeleccionado.dispose();
    ciudadSeleccionada.dispose();
  }

  Future<bool> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    if (especialidadesSeleccionadas.isEmpty) {
      apiMessage = 'Seleccione al menos una especialidad';
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      print("API Base URL: $baseUrl");  // Imprime la URL base para verificar
      final url = Uri.parse('$baseUrl/register_profesional_basico.php');
      final body = {
        "tipo_documento": tipoDocumento.value,
        "numero_documento": numeroDocumentoController.text.trim(),
        "username": usernameController.text.trim(),
        "full_name": fullNameController.text.trim(),
        "password": passwordController.text,
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "fecha_nacimiento": _formatDate(birthDateController.text),
        "departamento": departamentoSeleccionado.value,
        "ciudad": ciudadSeleccionada.value,
        "postal_code": postalCodeController.text.trim(),
        "especialidades": _mapEspecialidadesToIds(),
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (!context.mounted) return false;

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        apiMessage = jsonResponse['message'] ?? 'Registro exitoso';
        return true;
      } else {
        apiMessage = jsonResponse['message'] ?? 'Error desconocido';
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      apiMessage = 'Error: ${e.toString()}';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatDate(String dateText) {
    try {
      final parts = dateText.split('/');
      if (parts.length == 3) {
        final dd = parts[0].padLeft(2, '0');
        final mm = parts[1].padLeft(2, '0');
        final yyyy = parts[2];
        return '$yyyy-$mm-$dd';
      }
    } catch (_) {}
    return dateText;
  }

  List<int> _mapEspecialidadesToIds() {
    final map = {
      'Limpieza': 1,
      'Cocina': 2,
      'Planchado': 3,
    };
    return especialidadesSeleccionadas
        .map((e) => map[e] ?? 0)
        .where((id) => id != 0)
        .toList();
  }
}
