import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientRegisterController with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // NUEVO: controladores tipo/número de documento
  String? tipoDocumentoSeleccionado;
  final List<String> tiposDocumento = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
  ];
  final TextEditingController numeroDocumentoController = TextEditingController();

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
    'Atlántico': [
      'Barranquilla',
      'Baranoa',
      'Campo de la Cruz',
      'Candelaria',
      'Galapa',
      'Juan de Acosta',
      'Luruaco',
      'Malambo',
      'Manatí',
      'Palmar de Varela',
      'Piojó',
      'Polonuevo',
      'Ponedera',
      'Puerto Colombia',
      'Repelón',
      'Sabanagrande',
      'Sabanalarga',
      'Santa Lucía',
      'Santo Tomás',
      'Soledad',
      'Suan',
      'Tubará',
      'Usiacurí',
    ],
    'Bolívar': [
      'Cartagena',
      'Achí',
      'Altos del Rosario',
      'Arenal',
      'Arjona',
      'Arroyohondo',
      'Barranco de Loba',
      'Calamar',
      'Cantagallo',
      'Cicuco',
      'Clemencia',
      'Córdoba',
      'El Carmen de Bolívar',
      'El Guamo',
      'El Peñón',
      'Hatillo de Loba',
      'Magangué',
      'Mahates',
      'Margarita',
      'María la Baja',
      'Montecristo',
      'Mompós',
      'Morales',
      'Norosí',
      'Pinillos',
      'Regidor',
      'Río Viejo',
      'San Cristóbal',
      'San Estanislao',
      'San Fernando',
      'San Jacinto',
      'San Jacinto del Cauca',
      'San Juan Nepomuceno',
      'San Martín de Loba',
      'San Pablo',
      'Santa Catalina',
      'Santa Rosa',
      'Santa Rosa del Sur',
      'Simití',
      'Soplaviento',
      'Talaigua Nuevo',
      'Tiquisio',
      'Turbaco',
      'Turbaná',
      'Villanueva',
      'Zambrano',
    ],
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
          'numero_documento': numeroDocumentoController.text.trim(),
        }),
      );

      final jsonResponse = json.decode(response.body);
      lastValidationResponse = jsonResponse;

      if (response.statusCode == 200) {
        if (jsonResponse['error'] == true ||
            (jsonResponse['message'] as String).contains('en uso')) {
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
        'tipo_documento': tipoDocumentoSeleccionado,
        'numero_documento': numeroDocumentoController.text.trim(),
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
    numeroDocumentoController.dispose();
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
