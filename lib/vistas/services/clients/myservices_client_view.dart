import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/controladores/services/clientmain_controller.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'page_container.dart';

class MyServicesClientView extends StatefulWidget {
  const MyServicesClientView({super.key});

  @override
  State<MyServicesClientView> createState() => _MyServicesClientViewState();
}

class _MyServicesClientViewState extends State<MyServicesClientView> {
  late Future<List<Map<String, dynamic>>> _serviciosFuturo;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _serviciosFuturo = ClientMainController().obtenerServiciosFinalizadosCliente(userProvider.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Servicios Finalizados",
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _serviciosFuturo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tienes servicios finalizados."));
          }
          final finalizados = snapshot.data!;
          return ListView.separated(
            itemCount: finalizados.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final servicio = finalizados[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${servicio['nombre_profesional']} (${servicio['nombre_especialidad']})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio final: \$${servicio['precio_final'] ?? servicio['precio_acordado'] ?? servicio['precio_cliente']}'),
                      Text('Fecha: ${servicio['fecha']}'),
                      Text('Descripción: ${servicio['descripcion']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final comentarioCtrl = TextEditingController();
                      int calificacion = 5;
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Calificar y comentar profesional'),
                          content: StatefulBuilder(
                            builder: (context, setState) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<int>(
                                  value: calificacion,
                                  items: List.generate(5, (i) => i + 1)
                                      .map((v) => DropdownMenuItem(value: v, child: Text('$v estrellas')))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        calificacion = v;
                                      });
                                    }
                                  },
                                ),
                                TextField(
                                  controller: comentarioCtrl,
                                  decoration: InputDecoration(labelText: 'Comentario'),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                final comentario = comentarioCtrl.text.trim();
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                final result = await ClientMainController().comentarCalificarProfesional(
                                  idCliente: userProvider.userId!,
                                  idProfesional: servicio['id_profesional'],
                                  comentario: comentario,
                                  calificacion: calificacion,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'] ?? 'Error al comentar/calificar')),
                                );
                                Navigator.pop(context);
                              },
                              child: Text('Guardar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Calificar y comentar"),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
