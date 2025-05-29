import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        
        print('Enviando datos: ${requestData.toString()}');

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
        debugPrint('Respuesta completa:');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Headers: ${response.headers}');
        debugPrint('Body: ${response.body}');

        // Manejo mejorado de la respuesta
        if (response.statusCode == 200) {
          try {
            final jsonResponse = json.decode(response.body);
            
            if (jsonResponse['status'] == 'success') {
              apiResponseMessage = 'Registro exitoso: ${jsonResponse['message']}';
              if (context.mounted) {
                showSnackBar(context, apiResponseMessage!, Colors.green);
              }
              return true;
            } else {
              apiResponseMessage = jsonResponse['message'] ?? 'Error desconocido del servidor';
              if (context.mounted) {
                showSnackBar(context, apiResponseMessage!, Colors.red);
              }
              return false;
            }
          } catch (e) {
            apiResponseMessage = 'Error procesando respuesta: ${e.toString()}';
            if (context.mounted) {
              showSnackBar(context, apiResponseMessage!, Colors.orange);
            }
            return false;
          }
        } else {
          apiResponseMessage = 'Error de conexión (${response.statusCode})';
          if (context.mounted) {
            showSnackBar(context, apiResponseMessage!, Colors.red);
          }
          return false;
        }
      } catch (e) {
        apiResponseMessage = 'Error inesperado: ${e.toString()}';
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