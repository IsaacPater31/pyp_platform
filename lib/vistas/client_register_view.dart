import 'package:flutter/material.dart';
import 'package:pyp_platform/controladores/client_register_controller.dart';

class ClientRegisterView extends StatefulWidget {
  const ClientRegisterView({super.key});

  @override
  State<ClientRegisterView> createState() => _ClientRegisterViewState();
}

class _ClientRegisterViewState extends State<ClientRegisterView> {
  late ClientRegisterController controller;

  @override
  void initState() {
    super.initState();
    controller = ClientRegisterController();
  }

  @override
  void dispose() {
    controller.dispose();
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
            key: controller.formKey,
            child: ListView(
              children: [
                _buildTextField(
                  label: 'Nombre de usuario único',
                  controller: controller.usernameController,
                ),
                _buildTextField(
                  label: 'Nombre completo',
                  controller: controller.fullNameController,
                ),
                _buildTextField(
                  label: 'Correo electrónico',
                  controller: controller.emailController,
                ),
                _buildTextField(
                  label: 'Teléfono',
                  controller: controller.phoneController,
                ),
                _buildTextField(
                  label: 'Contraseña',
                  controller: controller.passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildDepartamentoDropdown(),
                const SizedBox(height: 16),
                _buildMunicipioDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Dirección',
                  controller: controller.addressController,
                ),
                _buildTextField(
                  label: 'Código postal',
                  controller: controller.postalCodeController,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (controller.validateForm()) {
                      controller.printDatos();
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
      value: controller.departamentoSeleccionado,
      items: controller.departamentosYMunicipios.keys.map((String departamento) {
        return DropdownMenuItem<String>(
          value: departamento,
          child: Text(departamento),
        );
      }).toList(),
      onChanged: (String? nuevoDepartamento) {
        setState(() {
          controller.onDepartamentoChanged(nuevoDepartamento);
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
      value: controller.ciudadSeleccionada,
      items: controller.departamentoSeleccionado == null
          ? []
          : controller.departamentosYMunicipios[controller.departamentoSeleccionado]!
              .map((String municipio) {
                return DropdownMenuItem<String>(
                  value: municipio,
                  child: Text(municipio),
                );
              }).toList(),
      onChanged: controller.departamentoSeleccionado == null
          ? null
          : (String? nuevoMunicipio) {
              setState(() {
                controller.onCiudadChanged(nuevoMunicipio);
              });
            },
      validator: (value) {
        if (controller.departamentoSeleccionado != null && (value == null || value.isEmpty)) {
          return 'Seleccione una ciudad o municipio';
        }
        return null;
      },
      disabledHint: const Text('Seleccione primero un departamento'),
    );
  }
}
