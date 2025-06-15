import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/role_selection_view.dart';
import 'package:pyp_platform/controladores/login_controller.dart';
import 'package:pyp_platform/vistas/services/clients/main_client_view.dart';
import 'package:pyp_platform/vistas/services/profesionals/main_profesional_view.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/providers/user_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
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
                    onChanged: (value) {
                      setState(() {
                        _controller.selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo usuario
                  TextField(
                    controller: _controller.usernameController,
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
                    controller: _controller.passwordController,
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
                      onPressed: () async {
                        final loginResult = await _controller.login();

                        if (!context.mounted) return;

                        if (loginResult['success']) {
                          // GUARDAR usuario y rol usando Provider (sin ID aún)
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          final username = _controller.usernameController.text.trim();
                          final rol = _controller.selectedRole ?? '';

                          userProvider.login(username, rol);

                          // BUSCAR el ID y guardarlo en el provider
                          final userId = await _controller.buscarIdPorUsernameYRol(username, rol);
                          if (userId != null) {
                            userProvider.setUserId(userId);
                            // print('ID guardado en provider: $userId');
                          } else {
                            // Manejo si no se encuentra el ID (opcional)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No se pudo obtener el ID del usuario')),
                            );
                          }

                          // NAVEGAR
                          if (rol == 'profesional') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainProfesionalView()),
                            );
                          } else if (rol == 'cliente') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainClientView()),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loginResult['message'])),
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
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
