import 'package:flutter/material.dart';
import 'package:pyp_platform/controladores/client_register_controller.dart';
import 'package:pyp_platform/vistas/client_register_location_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientRegisterView extends StatefulWidget {
  const ClientRegisterView({super.key});

  @override
  State<ClientRegisterView> createState() => _ClientRegisterViewState();
}

class _ClientRegisterViewState extends State<ClientRegisterView> {
  late ClientRegisterController controller;
  bool _obscurePassword = true;
  bool _aceptaTerminos = false; // <-- NUEVO

  @override
  void initState() {
    super.initState();
    controller = ClientRegisterController();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!controller.validateForm()) return;

    // Validar términos y condiciones
    if (!_aceptaTerminos) {
      _showErrorMessage('Debes aceptar los términos y condiciones para continuar');
      return;
    }

    _showLoadingDialog();

    try {
      final validation = await controller.validarDatosBasicos();

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (validation['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(validation['message'] ?? 'Error desconocido'),
              backgroundColor: Colors.red),
        );
        return;
      }

      final locationSelected = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientRegisterLocationView(controller: controller),
        ),
      );

      if (!mounted) return;
      if (locationSelected == true) {
        _showLoadingDialog();
        final registration = await controller.completeRegistration();

        if (!mounted) return;
        Navigator.pop(context); // Cerrar loading

        if (registration['success'] == true) {
          if (!mounted) return;
          Navigator.pop(context); // Cerrar vista de registro
          _showSuccessMessage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(registration['message'] ?? 'Error al registrar'),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorMessage('Error: ${e.toString()}');
    }
  }

  void _showLoadingDialog() {
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

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro completado exitosamente'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  Future<void> _launchTermsURL() async {
    const url = 'https://pypplatform.liveblog365.com/TerminosCondiciones/';
    final Uri launchUrlUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(launchUrlUri)) {
        await launchUrl(launchUrlUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  // ====== VALIDACIONES FRONTEND MEJORADAS ======
  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'El $field es requerido';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha de nacimiento es requerida';
    }
    try {
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final birthDate = DateTime(year, month, day);
        final today = DateTime.now();
        final age = today.year - birthDate.year - ((today.month > birthDate.month || (today.month == birthDate.month && today.day >= birthDate.day)) ? 0 : 1);
        if (age < 18) {
          return 'Debes ser mayor de 18 años';
        }
      } else {
        return 'Formato de fecha inválido';
      }
    } catch (_) {
      return 'Fecha inválida';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'El teléfono es requerido';
    final phoneRegex = RegExp(r'^\d{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Ingrese un teléfono válido (solo números, mínimo 10)';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) return 'La contraseña debe tener mínimo 6 caracteres';
    return null;
  }
  // ==============================================

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
              // TIPO DE DOCUMENTO
              DropdownButtonFormField<String>(
                value: controller.tipoDocumentoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo de documento',
                  prefixIcon: const Icon(Icons.badge, color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                ),
                items: controller.tiposDocumento
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo, style: const TextStyle(color: Color(0xFF1F2937))),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.tipoDocumentoSeleccionado = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione tipo de documento' : null,
              ),
              const SizedBox(height: 16),

              // NÚMERO DE DOCUMENTO
              TextFormField(
                controller: controller.numeroDocumentoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de documento',
                  prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'El número de documento es requerido' : null,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Nombre de usuario',
                controller: controller.usernameController,
                icon: Icons.person_outline,
                validator: (v) => _validateRequired(v, "nombre de usuario"),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nombre completo',
                controller: controller.fullNameController,
                icon: Icons.badge_outlined,
                validator: (v) => _validateRequired(v, "nombre completo"),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Correo electrónico',
                controller: controller.emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Teléfono',
                controller: controller.phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              _buildDateField(validator: _validateBirthDate),
              const SizedBox(height: 16),
              _buildPasswordField(validator: _validatePassword),
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
                validator: (v) => _validateRequired(v, "código postal"),
              ),
              const SizedBox(height: 16),

              // Checkbox de términos y condiciones
              Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    onChanged: (value) {
                      setState(() {
                        _aceptaTerminos = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Acepto los términos y condiciones',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  TextButton(
                    onPressed: _launchTermsURL,
                    child: const Text(
                      'Leer Términos y Condiciones',
                      style: TextStyle(color: Color(0xFF1F2937)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _submitForm,
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

  Widget _buildDateField({String? Function(String?)? validator}) {
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
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
      validator: validator,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  Widget _buildPasswordField({String? Function(String?)? validator}) {
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
      validator: validator,
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
