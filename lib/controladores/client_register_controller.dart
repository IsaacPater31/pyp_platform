import 'package:flutter/material.dart';

class ClientRegisterController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // <-- Nuevo
  final TextEditingController postalCodeController = TextEditingController();

  String? departamentoSeleccionado;
  String? ciudadSeleccionada;

  final Map<String, List<String>> departamentosYMunicipios = {
  'Antioquia': [
    'Abejorral', 'Abriaquí', 'Alejandría', 'Amagá', 'Amalfi', 'Andes',
    'Angelópolis', 'Angostura', 'Anorí', 'Anzá', 'Apartadó', 'Arboletes',
    'Argelia', 'Armenia', 'Barbosa', 'Bello', 'Belmira', 'Betania',
    'Betulia', 'Briceño', 'Buriticá', 'Cáceres', 'Caicedo', 'Caldas',
    'Campamento', 'Cañasgordas', 'Caracolí', 'Caramanta', 'Carepa',
    'Carolina del Príncipe', 'Caucasia', 'Chigorodó', 'Cisneros',
    'Ciudad Bolívar', 'Cocorná', 'Concepción', 'Concordia', 'Copacabana',
    'Dabeiba', 'Donmatías', 'Ebéjico', 'El Bagre', 'El Carmen de Viboral',
    'El Peñol', 'El Retiro', 'El Santuario', 'Entrerríos', 'Envigado',
    'Fredonia', 'Frontino', 'Giraldo', 'Girardota', 'Gómez Plata',
    'Granada', 'Guadalupe', 'Guarne', 'Guatapé', 'Heliconia', 'Hispania',
    'Itagüí', 'Ituango', 'Jardín', 'Jericó', 'La Ceja', 'La Estrella',
    'La Pintada', 'La Unión', 'Liborina', 'Maceo', 'Marinilla', 'Medellín',
    'Montebello', 'Murindó', 'Mutatá', 'Nariño', 'Nechí', 'Necoclí',
    'Olaya', 'Peque', 'Pueblorrico', 'Puerto Berrío', 'Puerto Nare',
    'Puerto Triunfo', 'Remedios', 'Rionegro', 'Sabanalarga', 'Sabaneta',
    'Salgar', 'San Andrés de Cuerquia', 'San Carlos', 'San Francisco',
    'San Jerónimo', 'San José de la Montaña', 'San Juan de Urabá',
    'San Luis', 'San Pedro', 'San Pedro de Urabá', 'San Rafael',
    'San Roque', 'San Vicente', 'Santa Bárbara', 'Santa Fe de Antioquia',
    'Santa Rosa de Osos', 'Santo Domingo', 'Segovia', 'Sonsón',
    'Sopetrán', 'Támesis', 'Tarazá', 'Tarso', 'Titiribí', 'Toledo',
    'Turbo', 'Uramita', 'Urrao', 'Valdivia', 'Valparaíso', 'Vegachí',
    'Venecia', 'Vigía del Fuerte', 'Yalí', 'Yarumal', 'Yolombó',
    'Yondó', 'Zaragoza'
  ],
  'Cundinamarca': [
    'Agua de Dios', 'Albán', 'Anapoima', 'Anolaima', 'Apulo', 'Arbeláez',
    'Beltrán', 'Bituima', 'Bojacá', 'Cabrera', 'Cachipay', 'Cajicá',
    'Caparrapí', 'Cáqueza', 'Carmen de Carupa', 'Chaguaní', 'Chía',
    'Chipaque', 'Choachí', 'Chocontá', 'Cogua', 'Cota', 'Cucunubá',
    'El Colegio', 'El Peñón', 'El Rosal', 'Facatativá', 'Fómeque',
    'Fosca', 'Funza', 'Fúquene', 'Fusagasugá', 'Gachalá', 'Gachancipá',
    'Gachetá', 'Gama', 'Girardot', 'Granada', 'Guachetá', 'Guaduas',
    'Guasca', 'Guataquí', 'Guatavita', 'Guayabal de Síquima',
    'Guayabetal', 'Gutiérrez', 'Jerusalén', 'Junín', 'La Calera',
    'La Mesa', 'La Palma', 'La Peña', 'La Vega', 'Lenguazaque',
    'Machetá', 'Madrid', 'Manta', 'Medina', 'Mosquera', 'Nariño',
    'Nemocón', 'Nilo', 'Nimaima', 'Nocaima', 'Pacho', 'Paime', 'Pandi',
    'Paratebueno', 'Pasca', 'Puerto Salgar', 'Pulí', 'Quebradanegra',
    'Quetame', 'Quipile', 'Ricaurte', 'San Antonio del Tequendama',
    'San Bernardo', 'San Cayetano', 'San Francisco', 'San Juan de Rioseco',
    'Sasaima', 'Sesquilé', 'Sibaté', 'Silvania', 'Simijaca', 'Soacha',
    'Sopó', 'Subachoque', 'Suesca', 'Supatá', 'Susa', 'Sutatausa',
    'Tabio', 'Tausa', 'Tena', 'Tenjo', 'Tibacuy', 'Tibirita', 'Tocaima',
    'Tocancipá', 'Topaipí', 'Ubalá', 'Ubaque', 'Ubaté', 'Une', 'Útica',
    'Venecia', 'Vergara', 'Vianí', 'Villagómez', 'Villapinzón', 'Villeta',
    'Viotá', 'Yacopí', 'Zipacón', 'Zipaquirá'
  ],
  'Valle del Cauca': [
    'Alcalá', 'Andalucía', 'Ansermanuevo', 'Argelia', 'Bolívar',
    'Buenaventura', 'Buga', 'Bugalagrande', 'Caicedonia', 'Cali',
    'Calima', 'Candelaria', 'Cartago', 'Dagua', 'El Águila', 'El Cairo',
    'El Cerrito', 'El Dovio', 'Florida', 'Ginebra', 'Guacarí', 'Jamundí',
    'La Cumbre', 'La Unión', 'La Victoria', 'Obando', 'Palmira',
    'Pradera', 'Restrepo', 'Riofrío', 'Roldanillo', 'San Pedro',
    'Sevilla', 'Toro', 'Trujillo', 'Tuluá', 'Ulloa', 'Versalles',
    'Vijes', 'Yotoco', 'Yumbo', 'Zarzal'
  ],
  'Bolívar': [
    'Achí', 'Altos del Rosario', 'Arenal', 'Arjona', 'Arroyohondo',
    'Barranco de Loba', 'Calamar', 'Cantagallo', 'Cartagena', 'Cicuco',
    'Clemencia', 'Córdoba', 'El Carmen de Bolívar', 'El Guamo',
    'El Peñón', 'Hatillo de Loba', 'Magangué', 'Mahates', 'Margarita',
    'María La Baja', 'Mompós', 'Montecristo', 'Morales', 'Norosí',
    'Pinillos', 'Regidor', 'Río Viejo', 'San Cristóbal', 'San Estanislao',
    'San Fernando', 'San Jacinto', 'San Jacinto del Cauca',
    'San Juan Nepomuceno', 'San Martín de Loba', 'San Pablo',
    'Santa Catalina', 'Santa Rosa', 'Santa Rosa del Sur', 'Simití',
    'Soplaviento', 'Talaigua Nuevo', 'Tiquisio', 'Turbaco', 'Turbaná',
    'Villanueva', 'Zambrano'
  ],
  'Atlántico': [
    'Baranoa', 'Barranquilla', 'Campo de la Cruz', 'Candelaria',
    'Galapa', 'Juan de Acosta', 'Luruaco', 'Malambo', 'Manatí',
    'Palmar de Varela', 'Piojó', 'Polonuevo', 'Ponedera', 'Puerto Colombia',
    'Repelón', 'Sabanagrande', 'Sabanalarga', 'Santa Lucía', 'Santo Tomás',
    'Soledad', 'Suán', 'Tubará', 'Usiacurí'
  ],
};


  void onDepartamentoChanged(String? nuevo) {
    departamentoSeleccionado = nuevo;
    ciudadSeleccionada = null;
  }

  void onCiudadChanged(String? nuevaCiudad) {
    ciudadSeleccionada = nuevaCiudad;
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

  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose(); 
    postalCodeController.dispose();
  }
}
