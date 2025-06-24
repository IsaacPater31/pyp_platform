import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'package:pyp_platform/models/servicio_model.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'page_container.dart';

class MyServicesProfesionalView extends StatefulWidget {
  const MyServicesProfesionalView({super.key});

  @override
  State<MyServicesProfesionalView> createState() => _MyServicesProfesionalViewState();
}

class _MyServicesProfesionalViewState extends State<MyServicesProfesionalView> {
  late Future<List<ServicioModel>> _serviciosFuturo;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _serviciosFuturo = ProfessionalMainController().obtenerServiciosFinalizadosProfesional(userProvider.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Servicios Finalizados",
      child: FutureBuilder<List<ServicioModel>>(
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
                  title: Text('${servicio.nombreCliente} (${servicio.nombreEspecialidad})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio final: \$${servicio.precioFinal ?? servicio.precioAcuerdo ?? servicio.precioCliente}'),
                      Text('Fecha: ${servicio.fecha}'),
                      Text('Ciudad: ${servicio.ciudadCliente}'),
                      Text('Descripción: ${servicio.descripcion}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final comentarioCtrl = TextEditingController();
                      int calificacion = 5;
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Calificar y comentar cliente'),
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
                                final result = await ProfessionalMainController().comentarCalificarCliente(
                                  idProfesional: userProvider.userId!,
                                  idCliente: servicio.idCliente,
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
