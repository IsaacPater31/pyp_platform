import 'package:flutter/material.dart';

class ClientRegisterController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  String? departamentoSeleccionado;
  String? ciudadSeleccionada;

  final Map<String, List<String>> departamentosYMunicipios = {
    'Antioquia': ['Medellín', 'Envigado', 'Bello', 'Itagüí'],
    'Cundinamarca': ['Bogotá', 'Soacha', 'Zipaquirá', 'Chía'],
    'Valle del Cauca': ['Cali', 'Palmira', 'Buenaventura', 'Tuluá'],
    'Bolívar': ['Cartagena', 'Magangué', 'Turbaco', 'Arjona', 'El Carmen de Bolívar', 'San Juan Nepomuceno'],
  };

  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    postalCodeController.dispose();
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void onDepartamentoChanged(String? nuevoDepartamento) {
    departamentoSeleccionado = nuevoDepartamento;
    ciudadSeleccionada = null;
  }

  void onCiudadChanged(String? nuevoMunicipio) {
    ciudadSeleccionada = nuevoMunicipio;
  }

  // Método para imprimir los datos ingresados (desde el controlador)
  void printDatos() {
    print('--- Datos del formulario ---');
    print('Usuario: ${usernameController.text}');
    print('Nombre completo: ${fullNameController.text}');
    print('Correo: ${emailController.text}');
    print('Teléfono: ${phoneController.text}');
    print('Contraseña: ${passwordController.text}');
    print('Departamento: $departamentoSeleccionado');
    print('Ciudad o Municipio: $ciudadSeleccionada');
    print('Código postal: ${postalCodeController.text}');
    print('----------------------------');
  }
}
