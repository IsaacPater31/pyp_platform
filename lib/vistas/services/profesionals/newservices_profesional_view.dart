import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/vistas/services/profesionals/page_container.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'package:pyp_platform/models/servicio_model.dart';
import 'package:pyp_platform/providers/user_provider.dart';

class NewServicesProfesionalView extends StatefulWidget {
  const NewServicesProfesionalView({super.key});

  @override
  State<NewServicesProfesionalView> createState() => _NewServicesProfesionalViewState();
}

class _NewServicesProfesionalViewState extends State<NewServicesProfesionalView> {
  late Future<List<ServicioModel>> _serviciosFuturo;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Debes asegurarte de tener el id del profesional en el userProvider
    _serviciosFuturo = ProfessionalMainController().obtenerServiciosActivosProfesional(userProvider.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Servicios Disponibles",
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<ServicioModel>>(
          future: _serviciosFuturo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No hay servicios nuevos por ahora.",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // Filtra solo los servicios en 'esperando_profesional'
            final nuevos = snapshot.data!.where((s) => s.estado == "esperando_profesional").toList();

            if (nuevos.isEmpty) {
              return Center(
                child: Text(
                  "No hay servicios esperando profesional.",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.separated(
              itemCount: nuevos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final servicio = nuevos[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      child: Text(servicio.nombreCliente.isNotEmpty ? servicio.nombreCliente[0] : "?"),
                    ),
                    title: Text('${servicio.nombreCliente} (${servicio.nombreEspecialidad})'),
                    subtitle: Text('Pago propuesto: \$${servicio.precioCliente}\n${servicio.descripcion}'),
                    isThreeLine: true,
                    trailing: ElevatedButton.icon(
                      onPressed: servicio.yaOferto > 0
                          ? null // Ya ofertó, botón deshabilitado
                          : () {
                              // Aquí llamas a tu método para postularse/ofertar
                              // await ofertarAlServicio(servicio.id, ...);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('¡Te postulaste al servicio!')),
                              );
                            },
                      icon: const Icon(Icons.handshake_rounded),
                      label: Text(servicio.yaOferto > 0 ? "Ya ofertaste" : "Postularse"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Detalle del Servicio'),
                          content: Text(
                            'Cliente: ${servicio.nombreCliente}\n'
                            'Especialidad: ${servicio.nombreEspecialidad}\n'
                            'Pago: \$${servicio.precioCliente}\n'
                            'Descripción: ${servicio.descripcion}\n'
                            'Ciudad: ${servicio.ciudadCliente}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
