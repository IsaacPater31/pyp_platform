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

  void printDatos() {
    print('--- Datos de registro ---');
    print('Usuario: ${usernameController.text}');
    print('Nombre: ${fullNameController.text}');
    print('Correo: ${emailController.text}');
    print('Teléfono: ${phoneController.text}');
    print('Contraseña: ${passwordController.text}');
    print('Departamento: $departamentoSeleccionado');
    print('Ciudad: $ciudadSeleccionada');
    print('Dirección: ${addressController.text}');
    print('Código postal: ${postalCodeController.text}');
  }

  Future<bool> enviarDatosAlApi(BuildContext context) async {
    if (!validateForm()) return false;
    
    isLoading = true;
    notifyListeners();
    
    try {
      final url = Uri.parse('http://192.168.1.1/apispyp/register_client.php');
      
      final response = await http.post(url, body: {
        'username': usernameController.text.trim(),
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'departamento': departamentoSeleccionado ?? '',
        'ciudad': ciudadSeleccionada ?? '',
        'postal_code': postalCodeController.text.trim(),
        'direccion': addressController.text.trim(),
      });

      final jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (jsonResponse['status'] == 'success') {
          apiResponseMessage = jsonResponse['message'];
          showSnackBar(context, 'Registro exitoso', Colors.green);
          return true;
        } else {
          apiResponseMessage = jsonResponse['message'];
          showSnackBar(context, apiResponseMessage!, Colors.red);
          return false;
        }
      } else {
        apiResponseMessage = 'Error en la conexión: ${response.statusCode}';
        showSnackBar(context, apiResponseMessage!, Colors.red);
        return false;
      }
    } catch (e) {
      apiResponseMessage = 'Error: ${e.toString()}';
      showSnackBar(context, apiResponseMessage!, Colors.red);
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