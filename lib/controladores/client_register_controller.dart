import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientRegisterController with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController addressDetailController = TextEditingController();

  String? departamentoSeleccionado;
  String? ciudadSeleccionada;
  String? apiResponseMessage;
  bool isLoading = false;
  LatLng? selectedLocation;
  String? selectedAddress;

  final Map<String, List<String>> departamentosYMunicipios = {
    'Antioquia': ['Abejorral', 'Abriaquí'],
    'Cundinamarca': ['Agua de Dios', 'Albán'],
  };

  Map<String, dynamic>? lastValidationResponse;
  Map<String, dynamic>? lastRegistrationResponse;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://api.local/apispyp';

  void onDepartamentoChanged(String? nuevo) {
    departamentoSeleccionado = nuevo;
    ciudadSeleccionada = null;
    notifyListeners();
  }

  void onCiudadChanged(String? nuevaCiudad) {
    ciudadSeleccionada = nuevaCiudad;
    notifyListeners();
  }

  void setLocation(LatLng location, String address) {
    selectedLocation = location;
    selectedAddress = address;
    notifyListeners();
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Future<Map<String, dynamic>> validarDatosBasicos() async {
    if (!validateForm()) return {'success': false, 'message': 'Formulario no válido'};
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/validation.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
        }),
      );

      final jsonResponse = json.decode(response.body);
      lastValidationResponse = jsonResponse;

      if (response.statusCode == 200) {
        if (jsonResponse['error'] == true ||
            jsonResponse['message'].contains('en uso')) {
          apiResponseMessage = jsonResponse['message'];
          return {'success': false, 'message': apiResponseMessage};
        }
        return {'success': true};
      } else {
        apiResponseMessage = 'Error de conexión (${response.statusCode})';
        return {'success': false, 'message': apiResponseMessage};
      }
    } catch (e) {
      apiResponseMessage = 'Error: ${e.toString()}';
      return {'success': false, 'message': apiResponseMessage};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> completeRegistration() async {
    if (selectedLocation == null) {
      return {'success': false, 'message': 'Debes seleccionar una ubicación'};
    }

    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/register_client.php');
      String formattedDate = '';
      if (birthDateController.text.isNotEmpty) {
        final parts = birthDateController.text.split('/');
        if (parts.length == 3) {
          formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      final requestBody = {
        'username': usernameController.text.trim(),
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'fecha_nacimiento': formattedDate,
        'departamento': departamentoSeleccionado ?? '',
        'ciudad': ciudadSeleccionada ?? '',
        'postal_code': postalCodeController.text.trim(),
        'detalle_direccion': addressDetailController.text.trim(),
        'latitud': selectedLocation!.latitude.toString(),
        'longitud': selectedLocation!.longitude.toString(),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        final baseMessage =
            jsonResponse['message'] ?? 'Error en el registro (${response.statusCode})';
        final errors = jsonResponse['errors'] as Map<String, dynamic>? ?? {};
        apiResponseMessage = errors.isNotEmpty
            ? '$baseMessage\nErrores: ${errors.values.join(', ')}'
            : baseMessage;
        return {'success': false, 'message': apiResponseMessage};
      }
    } catch (e) {
      apiResponseMessage = 'Error de conexión: ${e.toString()}';
      return {'success': false, 'message': apiResponseMessage};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    passwordController.dispose();
    postalCodeController.dispose();
    addressDetailController.dispose();
    super.dispose();
  }
}
