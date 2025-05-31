import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:pyp_platform/vistas/register_view_success.dart';

class ClientRegisterController with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController addressDetailController = TextEditingController();

  // Variables de estado
  String? departamentoSeleccionado;
  String? ciudadSeleccionada;
  String? apiResponseMessage;
  bool isLoading = false;
  LatLng? selectedLocation;
  String? selectedAddress;

  // Departamentos y municipios
  final Map<String, List<String>> departamentosYMunicipios = {
    'Antioquia': ['Abejorral', 'Abriaquí'],
    'Cundinamarca': ['Agua de Dios', 'Albán'],
  };

  // Debug variables
  Map<String, dynamic>? lastValidationResponse;
  Map<String, dynamic>? lastRegistrationResponse;

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

  Future<bool> validarDatosBasicos(BuildContext context) async {
    if (!validateForm()) return false;
    
    isLoading = true;
    notifyListeners();
    
    try {
      final url = Uri.parse('http://192.168.1.2/apispyp/validation.php');
      final requestBody = {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
      };

      debugPrint('[API VALIDATION] Enviando solicitud a: $url');
      debugPrint('[API VALIDATION] Datos enviados: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      debugPrint('[API VALIDATION] Respuesta recibida:');
      debugPrint('[API VALIDATION] Status: ${response.statusCode}');
      debugPrint('[API VALIDATION] Body: ${response.body}');

      final jsonResponse = json.decode(response.body);
      lastValidationResponse = jsonResponse;

      if (response.statusCode == 200) {
        if (jsonResponse['error'] == true) {
          apiResponseMessage = jsonResponse['message'] ?? 'Error en la validación';
          showSnackBar(context, apiResponseMessage!, Colors.red);
          return false;
        }
        
        debugPrint('[API VALIDATION] Validación exitosa');
        return true;
      } else {
        apiResponseMessage = 'Error de conexión (${response.statusCode})';
        showSnackBar(context, apiResponseMessage!, Colors.red);
        return false;
      }
    } catch (e) {
      debugPrint('[API VALIDATION] Error: ${e.toString()}');
      apiResponseMessage = 'Error: ${e.toString()}';
      showSnackBar(context, apiResponseMessage!, Colors.red);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

          Future<bool> completeRegistration(BuildContext context) async {
          if (selectedLocation == null) {
            showSnackBar(context, 'Debes seleccionar una ubicación', Colors.red);
            return false;
          }

          isLoading = true;
          notifyListeners();

          try {
            final url = Uri.parse('http://192.168.1.2/apispyp/register_client.php');
            
            // Convertir fecha al formato YYYY-MM-DD que espera MySQL
            String formattedDate = '';
            try {
              if (birthDateController.text.isNotEmpty) {
                final parts = birthDateController.text.split('/');
                formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
              }
            } catch (e) {
              debugPrint('Error formateando fecha: $e');
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

            debugPrint('Datos a enviar: $requestBody');

            final response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Accept': 'application/json',
              },
              body: jsonEncode(requestBody),
            ).timeout(const Duration(seconds: 30));

            debugPrint('Respuesta del servidor: ${response.statusCode} - ${response.body}');

            if (response.statusCode == 201) {
              final jsonResponse = jsonDecode(response.body);
              if (jsonResponse['success'] == true) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RegisterSuccessView()),
                  );
                }
                return true;
              } else {
                apiResponseMessage = jsonResponse['message'] ?? 'Error en el registro';
              }
            } else {
              apiResponseMessage = 'Error del servidor (${response.statusCode})';
            }
            
            showSnackBar(context, apiResponseMessage!, Colors.red);
            return false;
          } catch (e) {
            debugPrint('Error en registro: $e');
            apiResponseMessage = 'Error de conexión: ${e.toString()}';
            showSnackBar(context, apiResponseMessage!, Colors.red);
            return false;
          } finally {
            isLoading = false;
            notifyListeners();
          }
        }

  void showSnackBar(BuildContext context, String message, Color color) {
    debugPrint('[UI] Mostrando Snackbar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
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