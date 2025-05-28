import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;

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

  // Ubicación seleccionada en el mapa
  latlong.LatLng? ubicacionSeleccionada;

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

  // Método para guardar la ubicación seleccionada desde el mapa
  void setUbicacionSeleccionada(latlong.LatLng ubicacion) {
    ubicacionSeleccionada = ubicacion;
  }

  // Validación final para asegurarse que la ubicación también fue seleccionada
  bool validateUbicacion() {
    return ubicacionSeleccionada != null;
  }
}
