import 'package:flutter/material.dart';
import 'page_container.dart';

class NewServicesProfesionalView extends StatefulWidget {
  const NewServicesProfesionalView({super.key});

  @override
  State<NewServicesProfesionalView> createState() => _NewServicesProfesionalViewState();
}

class _NewServicesProfesionalViewState extends State<NewServicesProfesionalView> {
  // Simulación de servicios nuevos. Luego puedes traerlos de la API.
  final List<Map<String, Object?>> _servicios = [
    {
      'cliente': 'Isaac Paternina',
      'especialidad': 'Limpieza',
      'valor': 30000,
      'comentario': 'Es urgente, traer materiales.',
    },
    {
      'cliente': 'Laura Ríos',
      'especialidad': 'Cocina',
      'valor': 40000,
      'comentario': 'Para cumpleaños, solo tarde.',
    },
  ];

  void _postularseServicio(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Te postulaste al servicio!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Servicios Disponibles",
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _servicios.isEmpty
            ? Center(
                child: Text(
                  "No hay servicios nuevos por ahora.",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                itemCount: _servicios.length,
                separatorBuilder: (_, __) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final servicio = _servicios[index];
                  final cliente = servicio['cliente'] as String? ?? "?";
                  final especialidad = servicio['especialidad'] as String? ?? "?";
                  final valor = servicio['valor'] as int? ?? 0;
                  final comentario = servicio['comentario'] as String? ?? "";

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF1F2937),
                        foregroundColor: Colors.white,
                        child: Text(cliente.isNotEmpty ? cliente[0] : "?"),
                      ),
                      title: Text('$cliente ($especialidad)'),
                      subtitle: Text('Pago propuesto: \$$valor\n$comentario'),
                      isThreeLine: true,
                      trailing: ElevatedButton.icon(
                        onPressed: () => _postularseServicio(index),
                        icon: Icon(Icons.handshake_rounded),
                        label: Text("Postularse"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2937),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Detalle del Servicio'),
                            content: Text(
                              'Cliente: $cliente\n'
                              'Especialidad: $especialidad\n'
                              'Pago: \$$valor\n'
                              'Comentario: $comentario'
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
              ),
      ),
    );
  }
}
