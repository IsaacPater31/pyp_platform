import 'dart:convert';
import 'dart:io';
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

  int? idProfesional;   // <--- Nuevo: Guarda el ID profesional
  String? selfieUrl;    // <--- Nuevo: Guarda la URL de la selfie

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

  // --- PASO 1: Registro básico
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
        idProfesional = jsonResponse['profesional_id'];
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

  // --- PASO 2: Subida de selfie
  Future<bool> subirSelfie(File selfie) async {
    if (idProfesional == null) {
      apiMessage = 'No se encontró el ID del profesional.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/upload_foto_profesional.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['id_profesional'] = idProfesional.toString();
      request.files.add(await http.MultipartFile.fromPath('foto', selfie.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        selfieUrl = jsonResponse['url_foto'];  // <--- Nuevo: Guarda la URL pública
        apiMessage = jsonResponse['message'] ?? 'Selfie subida correctamente';
        return true;
      } else {
        apiMessage = jsonResponse['message'] ?? 'Error al subir la selfie';
        return false;
      }
    } catch (e) {
      apiMessage = 'Error al subir selfie: ${e.toString()}';
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
