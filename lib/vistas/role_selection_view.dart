import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/client_register_view.dart';
import 'package:pyp_platform/vistas/profesionals/first_registerview_profesionals.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({super.key});

  @override
  RoleSelectionViewState createState() => RoleSelectionViewState();
}

class RoleSelectionViewState extends State<RoleSelectionView> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6), // Color del fondo del appBar
        elevation: 0, // Para quitar la sombra del AppBar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1F2937), // Color de la flecha
          ),
          onPressed: () {
            Navigator.pop(context); // Navega atrás
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona tu rol',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Row(
                  children: [
                    _buildRoleCard(
                      role: 'Cliente',
                      imagePath: 'assets/images/client.jpg',
                      isSelected: selectedRole == 'cliente',
                      onTap: () {
                        setState(() => selectedRole = 'cliente');
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildRoleCard(
                      role: 'Profesional',
                      imagePath: 'assets/images/profesional.jpg',
                      isSelected: selectedRole == 'profesional',
                      onTap: () {
                        setState(() => selectedRole = 'profesional');
                      },
                    ),
                  ],
                ),
              ),

              if (selectedRole != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedRole == 'cliente') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientRegisterView()));
                      } else if (selectedRole == 'profesional') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FirstRegisterViewProfessionals()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF1F2937) : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
