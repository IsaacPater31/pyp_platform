import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/role_selection_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Bienvenido a',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF4B5563),
                  ),
                ),
                Text(
                  'P&P Platform',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          // Formulario centrado
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32), // antes era 48
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'assets/images/PYP.png',
                      width: 300,
                      height: 300,
                    ),
                  ),

                  // Campo de rol
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Selecciona tu rol',
                      prefixIcon: const Icon(Icons.account_circle_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                      DropdownMenuItem(value: 'profesional', child: Text('Profesional')),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),

                  // Campo usuario
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo contraseña
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón de iniciar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón para crear cuenta
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Redirigir a la pantalla de selección de roles
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RoleSelectionView()),
                        );
                      },
                      child: const Text(
                        '¿No estás registrado? Crea tu cuenta',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
