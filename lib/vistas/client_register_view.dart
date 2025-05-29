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
    controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerChange);
    controller.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
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
            child: Stack(
              children: [
                ListView(
                  children: [
                    _buildTextField(
                      label: 'Nombre de usuario único',
                      controller: controller.usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: 'Nombre completo',
                      controller: controller.fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: 'Correo electrónico',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: 'Teléfono',
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: 'Contraseña',
                      controller: controller.passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDepartamentoDropdown(),
                    const SizedBox(height: 16),
                    _buildMunicipioDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Dirección',
                      controller: controller.addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: 'Código postal',
                      controller: controller.postalCodeController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              final success = await controller.enviarDatosAlApi(context);
                              if (success) {
                                // Navegar a otra pantalla si es necesario
                                // Navigator.pushReplacement(...);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Registrarse',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
                if (controller.isLoading)
                  const Center(child: CircularProgressIndicator()),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDepartamentoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Departamento',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      value: controller.departamentoSeleccionado,
      items: controller.departamentosYMunicipios.keys.map((String departamento) {
        return DropdownMenuItem<String>(
          value: departamento,
          child: Text(departamento),
        );
      }).toList(),
      onChanged: (String? nuevoDepartamento) {
        controller.onDepartamentoChanged(nuevoDepartamento);
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              controller.onCiudadChanged(nuevoMunicipio);
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