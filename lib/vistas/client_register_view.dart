import 'package:flutter/material.dart';
import 'package:pyp_platform/controladores/client_register_controller.dart';
import 'package:pyp_platform/vistas/client_register_location_view.dart';

class ClientRegisterView extends StatefulWidget {
  const ClientRegisterView({super.key});

  @override
  State<ClientRegisterView> createState() => _ClientRegisterViewState();
}

class _ClientRegisterViewState extends State<ClientRegisterView> {
  late ClientRegisterController controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    controller = ClientRegisterController();
    controller.addListener(() {
      debugPrint('Controller updated - Loading: ${controller.isLoading}');
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!controller.validateForm()) {
      debugPrint('Form validation failed');
      return;
    }

    debugPrint('Starting basic data validation...');
    _showLoadingDialog(context);

    try {
      final isValid = await controller.validarDatosBasicos(context);
      if (!isValid || !mounted) {
        debugPrint('Basic validation failed');
        return;
      }

      if (mounted) Navigator.pop(context); // Cerrar loading
      
      debugPrint('Navigating to location view...');
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ClientRegisterLocationView(
            onLocationSelected: (latLng, address) {
              debugPrint('Location selected: $latLng');
              debugPrint('Full address: $address');
              controller.setLocation(latLng, address);
              Navigator.pop(context, true);
            },
          ),
        ),
      );

      if (success == true && mounted) {
        debugPrint('Completing registration...');
        _showLoadingDialog(context);
        final registrationSuccess = await controller.completeRegistration(context);
        if (mounted) Navigator.pop(context); // Cerrar loading
        
        if (registrationSuccess && mounted) {
          debugPrint('Registration successful');
          Navigator.pop(context); // Cerrar vista de registro
          _showSuccessMessage(context);
        } else {
          debugPrint('Registration failed');
          _showErrorMessage(context, 'Error al completar el registro');
        }
      }
    } catch (e) {
      debugPrint('Error in registration process: ${e.toString()}');
      if (mounted) {
        Navigator.pop(context);
        _showErrorMessage(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
        ),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro completado exitosamente'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Registro de Cliente',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildTextField(
                label: 'Nombre de usuario',
                controller: controller.usernameController,
                icon: Icons.person_outline,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nombre completo',
                controller: controller.fullNameController,
                icon: Icons.badge_outlined,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Correo electrónico',
                controller: controller.emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.contains('@') ? null : 'Email inválido',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Teléfono',
                controller: controller.phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length >= 10 ? null : 'Mínimo 10 dígitos',
              ),
              const SizedBox(height: 16),
              _buildDateField(context),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildDropdownDepartamento(),
              const SizedBox(height: 16),
              _buildDropdownCiudad(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Código postal',
                controller: controller.postalCodeController,
                icon: Icons.numbers_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,                         
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      validator: validator,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: controller.birthDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha de nacimiento',
        prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF1F2937),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          controller.birthDateController.text =
              "${date.day}/${date.month}/${date.year}";
        }
      },
      validator: (value) => value!.isEmpty ? 'Requerido' : null,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF6B7280),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      validator: (value) => value!.length >= 6 ? null : 'Mínimo 6 caracteres',
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  Widget _buildDropdownDepartamento() {
    return DropdownButtonFormField<String>(
      value: controller.departamentoSeleccionado,
      decoration: InputDecoration(
        labelText: 'Departamento',
        prefixIcon: const Icon(Icons.map_outlined, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      items: controller.departamentosYMunicipios.keys.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Color(0xFF1F2937))),
        );
      }).toList(),
      onChanged: controller.onDepartamentoChanged,
      validator: (value) => value == null ? 'Seleccione un departamento' : null,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  Widget _buildDropdownCiudad() {
    return DropdownButtonFormField<String>(
      value: controller.ciudadSeleccionada,
      decoration: InputDecoration(
        labelText: 'Ciudad/Municipio',
        prefixIcon: const Icon(Icons.location_city_outlined, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      items: controller.departamentoSeleccionado == null
          ? []
          : controller.departamentosYMunicipios[controller.departamentoSeleccionado]!
              .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Color(0xFF1F2937))),
                );
              }).toList(),
      onChanged: controller.onCiudadChanged,
      validator: (value) => value == null ? 'Seleccione una ciudad' : null,
      disabledHint: const Text('Seleccione un departamento primero', style: TextStyle(color: Color(0xFF6B7280))),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }
}