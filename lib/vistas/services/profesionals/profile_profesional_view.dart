import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/login_view.dart';
import 'package:pyp_platform/vistas/services/profesionals/page_container.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'package:pyp_platform/models/profesional_model.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileProfesionalView extends StatelessWidget {
  const ProfileProfesionalView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.username;

    return PageContainer(
      title: "Perfil",
      child: username == null
          ? const Center(child: Text("No hay usuario logueado"))
          : FutureBuilder<ProfesionalModel?>(
              future: ProfessionalMainController().obtenerDatosProfesional(username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text("No se pudo obtener la información del perfil."),
                  );
                }
                final profesional = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // FOTO DE PERFIL
                    if (profesional.fotoPerfil != null && profesional.fotoPerfil!.isNotEmpty) ...[
                      Center(
                        child: ClipOval(
                          child: Image.network(
                            '${dotenv.env['ARCHIVOS_URL'] ?? 'http://api.local/pyp_platform/profile_pictures'}/${profesional.fotoPerfil}',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 100, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF1F2937)),
                      title: Text(profesional.fullName),
                      subtitle: Text(profesional.email),
                    ),
                    ListTile(
                      leading: Icon(
                        profesional.estadoSuscripcion == "activa"
                            ? Icons.verified_user
                            : Icons.lock_outline,
                        color: profesional.estadoSuscripcion == "activa"
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: const Text(
                        "Estado de suscripción",
                        style: TextStyle(color: Color(0xFF1F2937)),
                      ),
                      subtitle: Text(
                        profesional.estadoSuscripcion == "activa"
                            ? "Activa"
                            : "Inactiva",
                        style: TextStyle(
                          color: profesional.estadoSuscripcion == "activa"
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Color(0xFF1F2937)),
                      title: Text(profesional.phone),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city, color: Color(0xFF1F2937)),
                      title: Text('${profesional.departamento}, ${profesional.ciudad}'),
                      subtitle: Text('Código Postal: ${profesional.postalCode}'),
                    ),
                    // ESPECIALIDADES (Chips)
                    if (profesional.especialidades.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.star_half, color: Color(0xFF6366F1)),
                        title: const Text(
                          'Especialidades',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        subtitle: Wrap(
                          spacing: 8,
                          children: profesional.especialidades.map<Widget>(
                            (esp) => Chip(
                              label: Text(esp, style: const TextStyle(color: Color(0xFF1F2937))),
                              backgroundColor: const Color(0xFFF3F4F6),
                            ),
                          ).toList(),
                        ),
                      ),
                      const Divider(),
                    ],
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: const Text(
                        "Valoración promedio",
                        style: TextStyle(color: Color(0xFF1F2937)),
                      ),
                      subtitle: Text(
                        profesional.valoracionPromedio != null
                            ? profesional.valoracionPromedio.toString()
                            : 'Sin valoración',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.work_history, color: Color(0xFF1F2937)),
                      title: const Text('Servicios realizados'),
                      subtitle: Text('${profesional.serviciosAdquiridos}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Color(0xFF1F2937)),
                      title: const Text('Miembro desde'),
                      subtitle: Text(profesional.fechaCreacion),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Cerrar sesión"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          Provider.of<UserProvider>(context, listen: false).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginView()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
