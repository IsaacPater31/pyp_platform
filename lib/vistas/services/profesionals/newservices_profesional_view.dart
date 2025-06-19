import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/vistas/services/profesionals/page_container.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'package:pyp_platform/models/servicio_model.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    _serviciosFuturo = ProfessionalMainController().obtenerServiciosActivosProfesional(userProvider.userId!);
  }

  void mostrarMapa(BuildContext context, ServicioModel servicio) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ubicación del cliente'),
        content: SizedBox(
          width: 300,
          height: 250,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(servicio.direccionLat, servicio.direccionLng),
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.pyp_platform',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(servicio.direccionLat, servicio.direccionLng),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "© OpenStreetMap contributors",
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void aceptarServicio(BuildContext context, ServicioModel servicio) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio aceptado.')),
    );
  }

  void ofertarServicio(BuildContext context, ServicioModel servicio) {
    final TextEditingController precioCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ofertar otro precio'),
        content: TextField(
          controller: precioCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Nuevo precio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Oferta enviada: \$${precioCtrl.text}')),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void rechazarServicio(BuildContext context, ServicioModel servicio) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio rechazado.')),
    );
  }

  Widget buildBotonesAccion({
    required VoidCallback onAceptar,
    required VoidCallback onOferta,
    required VoidCallback onRechazar,
    bool disabled = false,
  }) {
    // Súper mini y solo iconos
    const double iconSize = 17.0;
    const double btnSize = 30.0;
    final isSmall = MediaQuery.of(context).size.width < 400;

    List<Widget> botones = [
      _MiniIconButton(
        icon: Icons.check_circle,
        color: Colors.green,
        iconSize: iconSize,
        btnSize: btnSize,
        onTap: disabled ? null : onAceptar,
        tooltip: "Aceptar",
      ),
      _MiniIconButton(
        icon: Icons.monetization_on,
        color: Colors.orange,
        iconSize: iconSize,
        btnSize: btnSize,
        onTap: disabled ? null : onOferta,
        tooltip: "Ofertar",
      ),
      _MiniIconButton(
        icon: Icons.cancel,
        color: Colors.red,
        iconSize: iconSize,
        btnSize: btnSize,
        onTap: disabled ? null : onRechazar,
        tooltip: "Rechazar",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: isSmall
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: botones)
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: botones),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Servicios Disponibles",
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: const Color(0xFFF3F4F6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1F2937),
                            foregroundColor: Colors.white,
                            child: Text(servicio.nombreCliente.isNotEmpty ? servicio.nombreCliente[0] : "?"),
                          ),
                          title: Text('${servicio.nombreCliente} (${servicio.nombreEspecialidad})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text('Pago propuesto: \$${servicio.precioCliente}\n${servicio.descripcion}',
                              style: const TextStyle(fontSize: 13)),
                          isThreeLine: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Detalle del Servicio'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cliente: ${servicio.nombreCliente}'),
                                      Text('Especialidad: ${servicio.nombreEspecialidad}'),
                                      Text('Pago: \$${servicio.precioCliente}'),
                                      Text('Descripción: ${servicio.descripcion}'),
                                      Text('Ciudad: ${servicio.ciudadCliente}'),
                                      const SizedBox(height: 8),
                                      if (["profesional_asignado", "pendiente_materiales", "en_curso"].contains(servicio.estado))
                                        Text('Teléfono: ${servicio.telefonoCliente}'),
                                      Text('Reportes recibidos: ${servicio.reportesCliente}'),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.location_on),
                                        label: const Text("Ver ubicación en el mapa"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF1F2937),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => mostrarMapa(context, servicio),
                                      ),
                                    ],
                                  ),
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
                        buildBotonesAccion(
                          onAceptar: () => aceptarServicio(context, servicio),
                          onOferta: () => ofertarServicio(context, servicio),
                          onRechazar: () => rechazarServicio(context, servicio),
                          disabled: servicio.yaOferto > 0,
                        ),
                      ],
                    ),
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

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double iconSize;
  final double btnSize;
  final VoidCallback? onTap;
  final String tooltip;

  const _MiniIconButton({
    required this.icon,
    required this.color,
    required this.iconSize,
    required this.btnSize,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Ink(
        decoration: ShapeDecoration(
          color: isDisabled ? Colors.grey[400] : color.withOpacity(0.92),
          shape: const CircleBorder(),
        ),
        child: SizedBox(
          width: btnSize,
          height: btnSize,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, size: iconSize, color: Colors.white),
            onPressed: onTap,
            tooltip: tooltip,
          ),
        ),
      ),
    );
  }
}
