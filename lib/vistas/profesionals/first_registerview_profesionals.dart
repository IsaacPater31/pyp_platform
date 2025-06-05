import 'package:flutter/material.dart';

class FirstRegisterViewProfessionals extends StatefulWidget {
  const FirstRegisterViewProfessionals({super.key});

  @override
  State<FirstRegisterViewProfessionals> createState() => _FirstRegisterViewProfessionalsState();
}

class _FirstRegisterViewProfessionalsState extends State<FirstRegisterViewProfessionals> {
  final _formKey = GlobalKey<FormState>();

  final _numeroDocumentoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String? _tipoDocumento;
  String? _departamentoSeleccionado;
  String? _ciudadSeleccionada;
  bool _obscurePassword = true;
  DateTime? _selectedDate;

  final List<String> _especialidades = [];
  final List<String> especialidadesDisponibles = ['Limpieza', 'Cocina', 'Planchado'];

  final Map<String, List<String>> departamentosYMunicipios = {
    'Atlántico': ['Barranquilla', 'Soledad'],
    'Cundinamarca': ['Bogotá', 'Soacha'],
    // Agrega los que necesites
  };

  @override
  void dispose() {
    _numeroDocumentoController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  String? _validateTipoDocumento(String? value) {
    if (value == null) return 'Seleccione el tipo de documento';
    return null;
  }

  String? _validateNumeroDocumento(String? value) {
    if (_tipoDocumento == null) return 'Seleccione primero el tipo de documento';
    if (value == null || value.trim().isEmpty) return 'Ingrese el número de documento';

    final numDoc = value.trim();

    if (_tipoDocumento == 'Cédula de Ciudadanía') {
      if (!RegExp(r'^\d+$').hasMatch(numDoc)) return 'Solo números';
      if (numDoc.length < 8 || numDoc.length > 10) return 'La cédula debe tener entre 8 y 10 dígitos';
    } else if (_tipoDocumento == 'Tarjeta de Identidad') {
      if (!RegExp(r'^\d+$').hasMatch(numDoc)) return 'Solo números';
      if (numDoc.length < 6 || numDoc.length > 10) return 'La tarjeta debe tener entre 6 y 10 dígitos';
    } else if (_tipoDocumento == 'Cédula de Extranjería') {
      // Puede contener letras y números, generalmente de 6 a 15 caracteres
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

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate() && _especialidades.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Datos válidos!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else if (_especialidades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos una especialidad.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Registro Profesional - Datos Básicos',
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
          key: _formKey,
          child: Column(
            children: [
              // Tipo de documento
              DropdownButtonFormField<String>(
                value: _tipoDocumento,
                decoration: _inputDecoration('Tipo de documento', Icons.credit_card_outlined),
                items: const [
                  DropdownMenuItem(value: 'Cédula de Ciudadanía', child: Text('Cédula de Ciudadanía')),
                  DropdownMenuItem(value: 'Tarjeta de Identidad', child: Text('Tarjeta de Identidad')),
                  DropdownMenuItem(value: 'Cédula de Extranjería', child: Text('Cédula de Extranjería')),
                ],
                onChanged: (val) => setState(() {
                  _tipoDocumento = val;
                  _numeroDocumentoController.clear();
                }),
                validator: _validateTipoDocumento,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Número de documento
              TextFormField(
                controller: _numeroDocumentoController,
                keyboardType: _tipoDocumento == 'Cédula de Extranjería'
                    ? TextInputType.text
                    : TextInputType.number,
                decoration: _inputDecoration('Número de documento', Icons.numbers_outlined),
                validator: _validateNumeroDocumento,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Username
              _buildTextField(
                label: 'Nombre de usuario',
                controller: _usernameController,
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Nombre completo
              _buildTextField(
                label: 'Nombre completo',
                controller: _fullNameController,
                icon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
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
                controller: _emailController,
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
                controller: _phoneController,
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
                controller: _birthDateController,
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
                      _birthDateController.text = "${date.day}/${date.month}/${date.year}";
                    });
                  }
                },
                validator: _validateBirthDate,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Departamento
              DropdownButtonFormField<String>(
                value: _departamentoSeleccionado,
                decoration: _inputDecoration('Departamento', Icons.map_outlined),
                items: departamentosYMunicipios.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Color(0xFF1F2937))),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _departamentoSeleccionado = value;
                  _ciudadSeleccionada = null;
                }),
                validator: (value) => value == null ? 'Seleccione un departamento' : null,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Ciudad/Municipio
              DropdownButtonFormField<String>(
                value: _ciudadSeleccionada,
                decoration: _inputDecoration('Ciudad/Municipio', Icons.location_city_outlined),
                items: _departamentoSeleccionado == null
                    ? []
                    : departamentosYMunicipios[_departamentoSeleccionado]!
                        .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Color(0xFF1F2937))),
                          );
                        }).toList(),
                onChanged: (value) => setState(() => _ciudadSeleccionada = value),
                validator: (value) => value == null ? 'Seleccione una ciudad' : null,
                disabledHint: const Text('Seleccione un departamento primero', style: TextStyle(color: Color(0xFF6B7280))),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // Código postal
              _buildTextField(
                label: 'Código postal',
                controller: _postalCodeController,
                icon: Icons.numbers_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Especialidades (multiselección)
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
                  final selected = _especialidades.contains(esp);
                  return ChoiceChip(
                    label: Text(esp, style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF1F2937),
                    )),
                    selected: selected,
                    selectedColor: const Color(0xFF1F2937),
                    backgroundColor: const Color(0xFFF3F4F6),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          _especialidades.add(esp);
                        } else {
                          _especialidades.remove(esp);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
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
      decoration: _inputDecoration(label, icon),
      validator: validator,
      style: const TextStyle(color: Color(0xFF1F2937)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
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
    );
  }
}
