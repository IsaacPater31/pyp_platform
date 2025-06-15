import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';
import 'package:pyp_platform/controladores/services/clientmain_controller.dart';
import 'package:pyp_platform/models/client_model.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ProfileClientView extends StatelessWidget {
  const ProfileClientView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.username;

    // Coordenadas por defecto (Cartagena)
    const cartagenaLatLng = LatLng(10.391049, -75.479426);

    return PageContainer(
      title: "Perfil",
      child: username == null
          ? const Center(child: Text("No hay usuario logueado"))
          : FutureBuilder<ClientModel?>(
              future: ClientMainController().obtenerDatosCliente(username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text("No se pudo obtener la información del perfil."),
                  );
                }
                final cliente = snapshot.data!;

                // Si hay coordenadas en la API, úsalas (recuerda: lat y lng están invertidas)
                final bool hasCoords = cliente.lat != null && cliente.lng != null;
                final double mapLat = hasCoords ? cliente.lng! : cartagenaLatLng.latitude;
                final double mapLng = hasCoords ? cliente.lat! : cartagenaLatLng.longitude;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Color(0xFF1F2937)),
                      title: Text(cliente.fullName),
                      subtitle: Text(cliente.email),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Color(0xFF1F2937)),
                      title: Text(cliente.phone),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_city, color: Color(0xFF1F2937)),
                      title: Text('${cliente.departamento}, ${cliente.ciudad}'),
                      subtitle: Text('Código Postal: ${cliente.postalCode}'),
                    ),
                    if ((cliente.detalleDireccion.isNotEmpty) || hasCoords) ...[
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.home, color: Color(0xFF1F2937)),
                        title: Text("Dirección"),
                        subtitle: Text(
                          cliente.detalleDireccion.isNotEmpty
                              ? cliente.detalleDireccion
                              : 'Sin detalles',
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF1F2937), width: 1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(mapLat, mapLng),
                            initialZoom: 13,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: 'com.example.pyp_platform',
                            ),
                            if (hasCoords)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: LatLng(mapLat, mapLng),
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
                    ],
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.star, color: Colors.amber),
                      title: Text(
                        "Valoración promedio",
                        style: TextStyle(color: Color(0xFF1F2937)),
                      ),
                      subtitle: Text(
                        cliente.valoracionPromedio != null
                            ? cliente.valoracionPromedio!.toStringAsFixed(2)
                            : 'Sin valoración',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.work_history, color: Color(0xFF1F2937)),
                      title: Text('Servicios adquiridos'),
                      subtitle: Text('${cliente.serviciosAdquiridos}'),
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Color(0xFF1F2937)),
                      title: Text('Miembro desde'),
                      subtitle: Text(cliente.fechaCreacion),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
