import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/Client_location.dart';
  
class ClientRegisterView extends StatefulWidget {
  const ClientRegisterView({super.key});

  @override
  State<ClientRegisterView> createState() => _ClientRegisterViewState();
}

class _ClientRegisterViewState extends State<ClientRegisterView> {
  final _formKey = GlobalKey<FormState>();

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
    // Puedes seguir agregando otros departamentos y municipios si quieres
  };

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cliente'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  label: 'Nombre de usuario único',
                  controller: usernameController,
                ),
                _buildTextField(
                  label: 'Nombre completo',
                  controller: fullNameController,
                ),
                _buildTextField(
                  label: 'Correo electrónico',
                  controller: emailController,
                ),
                _buildTextField(
                  label: 'Teléfono',
                  controller: phoneController,
                ),
                _buildTextField(
                  label: 'Contraseña',
                  controller: passwordController,
                  obscureText: true,
                ),
                
                const SizedBox(height: 16),
                _buildDepartamentoDropdown(),
                const SizedBox(height: 16),
                _buildMunicipioDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Código postal',
                  controller: postalCodeController,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                     if (_formKey.currentState?.validate() ?? false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientLocationView(),
                          ),
                        );
                      }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDepartamentoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Departamento',
        border: OutlineInputBorder(),
      ),
      value: departamentoSeleccionado,
      items: departamentosYMunicipios.keys.map((String departamento) {
        return DropdownMenuItem<String>(
          value: departamento,
          child: Text(departamento),
        );
      }).toList(),
      onChanged: (String? nuevoDepartamento) {
        setState(() {
          departamentoSeleccionado = nuevoDepartamento;
          ciudadSeleccionada = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione un departamento';
        }
        return null;
      },
    );
  }

  Widget _buildMunicipioDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Ciudad o Municipio',
        border: OutlineInputBorder(),
      ),
      value: ciudadSeleccionada,
      items: departamentoSeleccionado == null
          ? []
          : departamentosYMunicipios[departamentoSeleccionado]!
              .map((String municipio) {
                return DropdownMenuItem<String>(
                  value: municipio,
                  child: Text(municipio),
                );
              }).toList(),
      onChanged: departamentoSeleccionado == null
          ? null
          : (String? nuevoMunicipio) {
              setState(() {
                ciudadSeleccionada = nuevoMunicipio;
              });
            },
      validator: (value) {
        if (departamentoSeleccionado != null && (value == null || value.isEmpty)) {
          return 'Seleccione una ciudad o municipio';
        }
        return null;
      },
      disabledHint: const Text('Seleccione primero un departamento'),
    );
  }
}
