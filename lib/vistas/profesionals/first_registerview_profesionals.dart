import 'package:flutter/material.dart';
import 'package:pyp_platform/controladores/profesionals/register_profesionals_firststep.dart';
import 'package:pyp_platform/vistas/profesionals/selfie_registerview_profesionals.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstRegisterViewProfessionals extends StatefulWidget {
  const FirstRegisterViewProfessionals({super.key});

  @override
  State<FirstRegisterViewProfessionals> createState() => _FirstRegisterViewProfessionalsState();
}

class _FirstRegisterViewProfessionalsState extends State<FirstRegisterViewProfessionals> {
  final ProfessionalFirstStepController controller = ProfessionalFirstStepController();

  bool _obscurePassword = true;
  DateTime? _selectedDate;
  bool _acceptTerms = false;

  final List<String> especialidadesDisponibles = ['Limpieza', 'Cocina', 'Planchado'];
  final Map<String, List<String>> departamentosYMunicipios = {
    'Atlántico': ['Barranquilla', 'Soledad'],
    'Cundinamarca': ['Bogotá', 'Soacha'],
  };

  @override
  void dispose() {
    controller.disposeControllers();
    controller.dispose();
    super.dispose();
  }

  String? _validateTipoDocumento(String? value) {
    if (value == null) return 'Seleccione el tipo de documento';
    return null;
  }

  String? _validateNumeroDocumento(String? value) {
    final tipo = controller.tipoDocumento.value;
    if (tipo == null) return 'Seleccione primero el tipo de documento';
    if (value == null || value.trim().isEmpty) return 'Ingrese el número de documento';

    final numDoc = value.trim();

    if (tipo == 'Cédula de Ciudadanía') {
      if (!RegExp(r'^\d+$').hasMatch(numDoc)) return 'Solo números';
      if (numDoc.length < 8 || numDoc.length > 10) return 'La cédula debe tener entre 8 y 10 dígitos';
    } else if (tipo == 'Cédula de Extranjería') {
      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(numDoc)) return 'Solo letras y números';
      if (numDoc.length < 6 || numDoc.length > 15) return 'La cédula de extranjería debe tener entre 6 y 15 caracteres';
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (_selectedDate == null) return 'Seleccione la fecha de nacimiento';
    final now = DateTime.now();
    final age = now.year - _selectedDate!.year - ((now.month > _selectedDate!.month || (now.month == _selectedDate!.month && now.day >= _selectedDate!.day)) ? 0 : 1);
    if (age < 18) return 'Debes ser mayor de 18 años';
    return null;
  }

  Future<void> _launchURL() async {
    const url = 'https://pypplatform.liveblog365.com/TerminosCondiciones/';
    final Uri _url = Uri.parse(url);
    try {
      if (await canLaunchUrl(_url)) {
        await launchUrl(_url, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el enlace';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  void _submitForm() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos y condiciones para continuar'), backgroundColor: Colors.red),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final success = await controller.submit(context);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.apiMessage), backgroundColor: Colors.green),
      );
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelfieRegisterViewProfessionals(controller: controller),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.apiMessage), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controllerField,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controllerField,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: validator,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Registro Profesional - Datos Básicos',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
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
              // Tipo de documento
              ValueListenableBuilder<String?>(
                valueListenable: controller.tipoDocumento,
                builder: (context, value, child) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: _inputDecoration('Tipo de documento', Icons.credit_card_outlined),
                    items: const [
                      DropdownMenuItem(value: 'Cédula de Ciudadanía', child: Text('Cédula de Ciudadanía')),
                      DropdownMenuItem(value: 'Cédula de Extranjería', child: Text('Cédula de Extranjería')),
                    ],
                    onChanged: (val) {
                      controller.tipoDocumento.value = val;
                      controller.numeroDocumentoController.clear();
                    },
                    validator: _validateTipoDocumento,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Color(0xFF1F2937)),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Número de documento
              _buildTextField(
                label: 'Número de documento',
                controllerField: controller.numeroDocumentoController,
                icon: Icons.numbers_outlined,
                keyboardType: controller.tipoDocumento.value == 'Cédula de Extranjería'
                    ? TextInputType.text
                    : TextInputType.number,
                validator: _validateNumeroDocumento,
              ),
              const SizedBox(height: 16),

              // Username
              _buildTextField(
                label: 'Nombre de usuario',
                controllerField: controller.usernameController,
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Nombre completo
              _buildTextField(
                label: 'Nombre completo',
                controllerField: controller.fullNameController,
                icon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: controller.passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Contraseña', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Correo electrónico
              _buildTextField(
                label: 'Correo electrónico',
                controllerField: controller.emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teléfono
              _buildTextField(
                label: 'Teléfono',
                controllerField: controller.phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final phoneRegex = RegExp(r'^\d{10,}$');
                  if (!phoneRegex.hasMatch(v.trim())) return 'Teléfono inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              TextFormField(
                controller: controller.birthDateController,
                readOnly: true,
                decoration: _inputDecoration('Fecha de nacimiento', Icons.calendar_today_outlined),
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
                    setState(() {
                      _selectedDate = date;
                      controller.birthDateController.text = "${date.day}/${date.month}/${date.year}";
                    });
                  }
                },
                validator: _validateBirthDate,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Departamento
              ValueListenableBuilder<String?>(
                valueListenable: controller.departamentoSeleccionado,
                builder: (context, departamentoValue, _) {
                  return DropdownButtonFormField<String>(
                    value: departamentoValue,
                    decoration: _inputDecoration('Departamento', Icons.map_outlined),
                    items: departamentosYMunicipios.keys.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val, style: const TextStyle(color: Color(0xFF1F2937))),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.departamentoSeleccionado.value = val;
                      controller.ciudadSeleccionada.value = null;
                    },
                    validator: (val) => val == null ? 'Seleccione un departamento' : null,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Color(0xFF1F2937)),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Ciudad
              ValueListenableBuilder<String?>(
                valueListenable: controller.departamentoSeleccionado,
                builder: (context, departamentoValue, _) {
                  final ciudades = departamentoValue == null
                      ? <String>[]
                      : departamentosYMunicipios[departamentoValue] ?? [];
                  return ValueListenableBuilder<String?>(
                    valueListenable: controller.ciudadSeleccionada,
                    builder: (context, ciudadValue, _) {
                      return DropdownButtonFormField<String>(
                        value: ciudadValue,
                        decoration: _inputDecoration('Ciudad/Municipio', Icons.location_city_outlined),
                        items: ciudades
                            .map((val) => DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val, style: const TextStyle(color: Color(0xFF1F2937))),
                                ))
                            .toList(),
                        onChanged: ciudades.isEmpty
                            ? null
                            : (val) => controller.ciudadSeleccionada.value = val,
                        validator: (val) {
                          if (departamentoValue == null) return 'Seleccione un departamento primero';
                          return val == null ? 'Seleccione una ciudad' : null;
                        },
                        disabledHint: const Text('Seleccione un departamento primero', style: TextStyle(color: Color(0xFF6B7280))),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Color(0xFF1F2937)),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Código postal
              _buildTextField(
                label: 'Código postal',
                controllerField: controller.postalCodeController,
                icon: Icons.numbers_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Especialidades
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Especialidades (selecciona al menos una)',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: especialidadesDisponibles.map((esp) {
                  final selected = controller.especialidadesSeleccionadas.contains(esp);
                  return ChoiceChip(
                    label: Text(esp, style: TextStyle(color: selected ? Colors.white : const Color(0xFF1F2937))),
                    selected: selected,
                    selectedColor: const Color(0xFF1F2937),
                    backgroundColor: const Color(0xFFF3F4F6),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          controller.especialidadesSeleccionadas.add(esp);
                        } else {
                          controller.especialidadesSeleccionadas.remove(esp);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Términos y condiciones
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value!;
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
                    onPressed: _launchURL,
                    child: const Text(
                      'Leer Términos y Condiciones',
                      style: TextStyle(color: Color(0xFF1F2937)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Botón para enviar el formulario
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continuar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
