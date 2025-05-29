import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pyp_platform/vistas/register_view_success.dart';

class ClientRegisterController with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  // Variables de estado
  String? departamentoSeleccionado;
  String? ciudadSeleccionada;
  String? apiResponseMessage;
  bool isLoading = false;

  final Map<String, List<String>> departamentosYMunicipios = {
    'Antioquia': [
      'Abejorral', 'Abriaquí', 'Alejandría', 'Amagá', 'Amalfi', 'Andes',
      'Angelópolis', 'Angostura', 'Anorí', 'Anzá', 'Apartadó', 'Arboletes',
      // ... (mantener el resto de municipios)
    ],
    'Cundinamarca': [
      'Agua de Dios', 'Albán', 'Anapoima', 'Anolaima', 'Apulo', 'Arbeláez',
      // ... (mantener el resto de municipios)
    ],
    // ... (mantener otros departamentos)
  };

  void onDepartamentoChanged(String? nuevo) {
    departamentoSeleccionado = nuevo;
    ciudadSeleccionada = null;
    notifyListeners();
  }

  void onCiudadChanged(String? nuevaCiudad) {
    ciudadSeleccionada = nuevaCiudad;
    notifyListeners();
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

        Future<bool> enviarDatosAlApi(BuildContext context) async {
      if (!validateForm()) return false;
      
      isLoading = true;
      notifyListeners();
      
      try {
        final url = Uri.parse('http://192.168.1.1/apispyp/register_client.php');
        
        // Datos para depuración (sin contraseña real)
        final requestData = {
          'username': usernameController.text.trim(),
          'full_name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'password': '•••••••', // Oculta la contraseña real en logs
          'departamento': departamentoSeleccionado ?? '',
          'ciudad': ciudadSeleccionada ?? '',
          'postal_code': postalCodeController.text.trim(),
          'direccion': addressController.text.trim(),
        };
        
        debugPrint('Enviando datos de registro: $requestData');

        final response = await http.post(
          url,
          body: {
            ...requestData,
            'password': passwordController.text, // Envía la contraseña real aquí
          },
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );

        // Depuración detallada
        debugPrint('Respuesta del servidor:');
        debugPrint('Código de estado: ${response.statusCode}');
        debugPrint('Cabeceras: ${response.headers}');
        debugPrint('Cuerpo: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final jsonResponse = json.decode(response.body);
            
            if (jsonResponse['status'] == 'success') {
              debugPrint('Registro exitoso. Datos: $jsonResponse');
              
              // Redirigir a pantalla de éxito sin mostrar SnackBar
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const RegisterSuccessView(),
                  ),
                );
              }
              return true;
            } else {
              apiResponseMessage = jsonResponse['message'] ?? 'Error desconocido del servidor';
              debugPrint('Error en el registro: $apiResponseMessage');
              if (context.mounted) {
                showSnackBar(context, apiResponseMessage!, Colors.red);
              }
              return false;
            }
          } catch (e) {
            apiResponseMessage = 'Error procesando respuesta: ${e.toString()}';
            debugPrint('Error decodificando JSON: $apiResponseMessage');
            if (context.mounted) {
              showSnackBar(context, apiResponseMessage!, Colors.orange);
            }
            return false;
          }
        } else {
          apiResponseMessage = 'Error de conexión (${response.statusCode})';
          debugPrint('Error HTTP: $apiResponseMessage');
          if (context.mounted) {
            showSnackBar(context, apiResponseMessage!, Colors.red);
          }
          return false;
        }
      } catch (e) {
        apiResponseMessage = 'Error inesperado: ${e.toString()}';
        debugPrint('Excepción no controlada: $apiResponseMessage');
        if (context.mounted) {
          showSnackBar(context, apiResponseMessage!, Colors.red);
        }
        return false;
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }
}