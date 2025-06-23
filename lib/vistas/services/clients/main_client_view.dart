import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'package:pyp_platform/controladores/services/clientmain_controller.dart';
import 'myservices_client_view.dart';
import 'stats_client_view.dart';
import 'news_client.dart';
import 'profile_client_view.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';
import 'package:pyp_platform/vistas/services/clients/bottom_menu_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class MainClientView extends StatefulWidget {
  const MainClientView({super.key});

  @override
  State<MainClientView> createState() => _MainClientViewState();
}

class _MainClientViewState extends State<MainClientView> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCentralIcon() {
    return FloatingActionButton(
      onPressed: () {
        _onItemTapped(2);
      },
      backgroundColor: const Color(0xFF1F2937),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Icon(Icons.add_box_rounded, size: 32, color: Colors.white),
    );
  }

  void _showCreateServiceForm(BuildContext context, VoidCallback onCreated) {
    showDialog(
      context: context,
      builder: (context) => CreateServiceDialog(
        onServiceCreated: ({
          required int idEspecialidad,
          required String descripcion,
          required double precioCliente,
          required String fecha,
          required String franjaHoraria,
        }) async {
          Navigator.pop(context);

          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final idCliente = userProvider.userId ?? 0;

          final controller = ClientMainController();
          final success = await controller.crearServicio(
            idCliente: idCliente,
            idEspecialidad: idEspecialidad,
            descripcion: descripcion,
            precioCliente: precioCliente,
            fecha: fecha,
            franjaHoraria: franjaHoraria,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '¡Servicio publicado correctamente!'
                  : 'Error al publicar el servicio. Intenta de nuevo.'),
            ),
          );
          onCreated();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final List<Widget> pages = [
      const MyServicesClientView(),
      const StatsClientView(),
      OfertasYCrearServicioClient(
        idCliente: userProvider.userId ?? 0,
        onCrearServicio: (VoidCallback onCreated) => _showCreateServiceForm(context, onCreated),
      ),
      const NewsClientView(),
      const ProfileClientView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 20,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomMenuIcon(
                icon: Icons.assignment_outlined,
                label: 'Mis Servicios',
                selected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              BottomMenuIcon(
                icon: Icons.bar_chart_outlined,
                label: 'Estadísticas',
                selected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48),
              BottomMenuIcon(
                icon: Icons.newspaper_outlined,
                label: 'Noticias',
                selected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
              BottomMenuIcon(
                icon: Icons.account_circle_outlined,
                label: 'Perfil',
                selected: _selectedIndex == 4,
                onTap: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCentralIcon(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ----------- Página central (Ofertas y crear servicio) ------------
class OfertasYCrearServicioClient extends StatefulWidget {
  final int idCliente;
  final void Function(VoidCallback onCreated) onCrearServicio;

  const OfertasYCrearServicioClient({
    required this.idCliente,
    required this.onCrearServicio,
    super.key,
  });

  @override
  State<OfertasYCrearServicioClient> createState() => _OfertasYCrearServicioClientState();
}

class _OfertasYCrearServicioClientState extends State<OfertasYCrearServicioClient> {
  late Future<List<Map<String, dynamic>>> _ofertasFuturo;

  @override
  void initState() {
    super.initState();
    _ofertasFuturo = ClientMainController().obtenerOfertasCliente(widget.idCliente);
  }

  Future<void> _refreshOfertas() async {
    setState(() {
      _ofertasFuturo = ClientMainController().obtenerOfertasCliente(widget.idCliente);
    });
  }

  void _showOfertaDetalles(Map<String, dynamic> oferta) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: OfertaDetallesDialog(oferta: oferta),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return PageContainer(
      title: "Tus Ofertas y Nuevo Servicio",
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => widget.onCrearServicio(_refreshOfertas),
              icon: Icon(Icons.add_box_rounded),
              label: Text('Crear nuevo servicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ofertasFuturo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No tienes ofertas activas por ahora.",
                        style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final ofertas = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshOfertas,
                    child: ListView.separated(
                      separatorBuilder: (_, __) => SizedBox(height: 16),
                      itemCount: ofertas.length,
                      itemBuilder: (context, index) {
                        final oferta = ofertas[index];
                        final profesional = oferta['nombre_profesional'] as String? ?? "?";
                        final fotoPerfilUrl = oferta['foto_perfil_url'] as String?;
                        final certificacion = oferta['certificacion_verificada'] == 'si';
                        final valoracion = oferta['valoracion_profesional']?.toString() ?? "-";
                        final reportes = oferta['reportes_profesional']?.toString() ?? "0";
                        final telefono = oferta['telefono_profesional']?.toString() ?? "";
                        final estadoServicio = (oferta['estado_servicio'] ?? "-").toString();

                        String estadoTexto;
                        Widget estadoIcono;

                        switch (estadoServicio) {
                          case 'esperando_profesional':
                            estadoTexto = "Nueva oferta";
                            estadoIcono = Icon(Icons.fiber_new, color: Colors.blue, size: 20);
                            break;
                          case 'profesional_asignado':
                            estadoTexto = "Profesional asignado";
                            estadoIcono = Icon(Icons.verified_user, color: Colors.green, size: 20);
                            break;
                          case 'en_curso':
                            estadoTexto = "En curso";
                            estadoIcono = Icon(Icons.directions_car, color: Colors.deepPurple, size: 20);
                            break;
                          case 'finalizado':
                            estadoTexto = "Servicio finalizado";
                            estadoIcono = Icon(Icons.check_circle, color: Colors.grey, size: 20);
                            break;
                          default:
                            estadoTexto = estadoServicio.replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
                            estadoIcono = Icon(Icons.hourglass_top, color: Colors.amber, size: 20);
                            break;
                        }

                        // Suponiendo que tienes el id del profesional actual en una variable: int idProfesionalActual;
                        // Y que en cada oferta tienes oferta['id_profesional']
                        final bool esProfesionalAsignadoActual = 
                            estadoServicio == 'profesional_asignado' &&
                            oferta['id_profesional']?.toString() == userProvider.userId.toString();

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFF1F2937),
                              foregroundColor: Colors.white,
                              backgroundImage: (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty)
                                  ? NetworkImage(fotoPerfilUrl)
                                  : null,
                              child: (fotoPerfilUrl == null || fotoPerfilUrl.isEmpty)
                                  ? Text(
                                      profesional.isNotEmpty ? profesional[0] : "?",
                                      style: TextStyle(fontSize: 24),
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    profesional,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                if (certificacion)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: Tooltip(
                                      message: "Certificación verificada",
                                      child: Icon(Icons.verified, color: Colors.blue, size: 20),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text(' $valoracion ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Icon(Icons.report, color: Colors.red, size: 16),
                                    Text(' $reportes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Spacer(),
                                    if (estadoServicio == 'esperando_profesional') ...[
                                      IconButton(
                                        icon: Icon(Icons.check_circle, color: Colors.green, size: 26),
                                        tooltip: "Aceptar",
                                        onPressed: () async {
                                          final controller = ClientMainController();
                                          final ok = await controller.aceptarOferta(oferta['id_oferta']);
                                          if (ok) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Oferta aceptada correctamente')),
                                            );
                                            _refreshOfertas();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('No se pudo aceptar la oferta')),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, color: Colors.red, size: 26),
                                        tooltip: "Rechazar",
                                        onPressed: () {
                                          // Acción rechazar (implementar)
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.price_change_rounded, color: Colors.orange, size: 26),
                                        tooltip: "Regatear",
                                        onPressed: () {
                                          // Acción regatear (implementar)
                                        },
                                      ),
                                    ] else if (esProfesionalAsignadoActual) ...[
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.playlist_add, color: Colors.white),
                                        label: Text("Generar lista de materiales"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () {
                                          // Acción para generar lista de materiales
                                        },
                                      ),
                                    ] else if (estadoServicio == 'profesional_asignado') ...[
                                      IconButton(
                                        icon: Icon(Icons.phone, color: Colors.green, size: 26),
                                        tooltip: "Llamar",
                                        onPressed: () {
                                          final tel = telefono.replaceAll(RegExp(r'[^0-9]'), '');
                                          if (tel.isNotEmpty) {
                                            launchUrl(Uri.parse('tel:+57$tel'));
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.chat, color: Colors.teal, size: 26),
                                        tooltip: "WhatsApp",
                                        onPressed: () {
                                          final tel = telefono.replaceAll(RegExp(r'[^0-9]'), '');
                                          if (tel.isNotEmpty) {
                                            launchUrl(Uri.parse('https://wa.me/57$tel'));
                                          }
                                        },
                                      ),
                                    ] else if (estadoServicio == 'en_curso') ...[
                                      IconButton(
                                        icon: Icon(Icons.phone, color: Colors.green, size: 26),
                                        tooltip: "Llamar",
                                        onPressed: () {
                                          final tel = telefono.replaceAll(RegExp(r'[^0-9]'), '');
                                          if (tel.isNotEmpty) {
                                            launchUrl(Uri.parse('tel:+57$tel'));
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.chat, color: Colors.teal, size: 26),
                                        tooltip: "WhatsApp",
                                        onPressed: () {
                                          final tel = telefono.replaceAll(RegExp(r'[^0-9]'), '');
                                          if (tel.isNotEmpty) {
                                            launchUrl(Uri.parse('https://wa.me/57$tel'));
                                          }
                                        },
                                      ),
                                    ] else if (estadoServicio == 'pendiente_materiales') ...[
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.inventory_2, color: Colors.white),
                                        label: Text("Ver materiales"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () async {
                                          final materiales = await ClientMainController().obtenerMaterialesServicio(oferta['id_servicio']);
                                          if (materiales.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("No hay materiales para este servicio.")),
                                            );
                                            return;
                                          }
                                          mostrarDialogoConfirmarMateriales(context, oferta['id_servicio'], materiales);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    estadoIcono,
                                    SizedBox(width: 8),
                                    Text(
                                      estadoTexto,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (estadoServicio == 'profesional_asignado') ...[
                                  SizedBox(height: 10),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide = constraints.maxWidth > 400;
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              "Esperando que el profesional mande la lista de materiales",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blueGrey[700],
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                                if (estadoServicio == 'validando_pin' && oferta['pin_validacion'] != null && oferta['pin_validacion'].toString().isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1F2937).withOpacity(0.07),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Color(0xFF1F2937), width: 1.2),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                      child: Column(
                                        children: [
                                          Text(
                                            "PIN de validación",
                                            style: TextStyle(
                                              color: Color(0xFF1F2937),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          SelectableText(
                                            oferta['pin_validacion'].toString(),
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                              letterSpacing: 8,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Dale este PIN al profesional cuando llegue.",
                                            style: TextStyle(color: Color(0xFF1F2937), fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () => _showOfertaDetalles(oferta),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------- Dialog para mostrar detalles de la oferta ---------
class OfertaDetallesDialog extends StatelessWidget {
  final Map<String, dynamic> oferta;

  const OfertaDetallesDialog({required this.oferta, super.key});

  @override
  Widget build(BuildContext context) {
    final profesional = oferta['nombre_profesional'] ?? "?";
    final especialidad = oferta['nombre_especialidad'] ?? "?";
    final valorOfertado = oferta['precio_ofertado'] ?? "-";
    final estado = oferta['estado_oferta'] ?? "-";
    final fotoPerfilUrl = oferta['foto_perfil_url'] as String?;
    final certificacion = oferta['certificacion_verificada'] == 'si';
    final valoracion = oferta['valoracion_profesional']?.toString() ?? "-";
    final reportes = oferta['reportes_profesional']?.toString() ?? "0";
    final descripcion = oferta['descripcion_servicio'] ?? "-";
    final fechaServicio = oferta['fecha_servicio'] ?? "-";
    final telefono = oferta['telefono_profesional'] ?? "-";
    final email = oferta['email_profesional'] ?? "-";
    final estadoServicio = oferta['estado_servicio'] ?? "-";
    final precioAcordado = oferta['precio_acordado'];
    final precioFinal = oferta['precio_final'];


    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF1F2937),
            foregroundColor: Colors.white,
            backgroundImage: (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty)
                ? NetworkImage(fotoPerfilUrl)
                : null,
            child: (fotoPerfilUrl == null || fotoPerfilUrl.isEmpty)
                ? Text(
                    profesional.isNotEmpty ? profesional[0] : "?",
                    style: TextStyle(fontSize: 32),
                  )
                : null,
          ),
          SizedBox(height: 16),
          Text(
            profesional,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            especialidad,
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
          ),
          SizedBox(height: 12),
          if (certificacion)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.blue, size: 20),
                SizedBox(width: 4),
                Text("Certificación verificada", style: TextStyle(color: Colors.blue)),
              ],
            ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              Text(' $valoracion   ', style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.report, color: Colors.red, size: 18),
              Text(' $reportes', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 32),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Descripción"),
            subtitle: Text(descripcion),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Fecha del servicio"),
            subtitle: Text(fechaServicio),
          ),
          if (estadoServicio == 'en_curso' && precioFinal != null && precioFinal.toString() != '' && precioFinal.toString() != 'null' && precioFinal.toString() != '-') ...[
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text("Precio final"),
              subtitle: Text('\$${getPrecio(precioFinal)}'),
            ),
          ] else if (estadoServicio == 'profesional_asignado' && precioAcordado != null && precioAcordado.toString() != '' && precioAcordado.toString() != 'null' && precioAcordado.toString() != '-') ...[
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text("Precio acordado"),
              subtitle: Text('\$${getPrecio(precioAcordado)}'),
            ),
          ] else ...[
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text("Valor ofertado"),
              subtitle: Text('\$${getPrecio(valorOfertado)}'),
            ),
          ],
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Estado de la oferta"),
            subtitle: Text(estado),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text("Teléfono"),
            subtitle: Text(telefono),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Correo"),
            subtitle: Text(email),
          ),
        ],
      ),
    );
  }
}

// --------- Dialog para crear servicio ---------
class CreateServiceDialog extends StatefulWidget {
  final void Function({
    required int idEspecialidad,
    required String descripcion,
    required double precioCliente,
    required String fecha,
    required String franjaHoraria,
  }) onServiceCreated;

  const CreateServiceDialog({
    required this.onServiceCreated,
    super.key,
  });

  @override
  State<CreateServiceDialog> createState() => _CreateServiceDialogState();
}

class _CreateServiceDialogState extends State<CreateServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _especialidadSeleccionada;
  String? _franjaSeleccionada;
  DateTime? _fechaSeleccionada;
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  final Map<String, int> especialidadMap = {
    "Limpieza": 1,
    "Cocina": 2,
    "Planchado": 3,
  };

  final List<String> franjas = [
    "mañana",
    "tarde",
    "noche",
  ];

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Crear Nuevo Servicio"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _especialidadSeleccionada,
                items: especialidadMap.keys
                    .map((nombre) => DropdownMenuItem(
                          value: nombre,
                          child: Text(nombre),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: "Especialidad"),
                onChanged: (value) {
                  setState(() {
                    _especialidadSeleccionada = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Selecciona una especialidad' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: "Descripción"),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: "Precio propuesto (COP)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = double.tryParse(value ?? "");
                  return v == null || v <= 0 ? 'Precio válido requerido' : null;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _franjaSeleccionada,
                items: franjas
                    .map((franja) => DropdownMenuItem(
                          value: franja,
                          child: Text(franja),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: "Franja horaria"),
                onChanged: (value) {
                  setState(() {
                    _franjaSeleccionada = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Selecciona una franja' : null,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Fecha",
                        errorText: _fechaSeleccionada == null ? "Selecciona una fecha" : null,
                        border: OutlineInputBorder(),
                      ),
                      child: TextButton(
                        onPressed: () => _pickDate(context),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _fechaSeleccionada == null
                                ? "Selecciona una fecha"
                                : "${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              color: _fechaSeleccionada == null ? Colors.grey : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final isFormValid = _formKey.currentState!.validate();
            final isDateSelected = _fechaSeleccionada != null;
            if (isFormValid && isDateSelected) {
              widget.onServiceCreated(
                idEspecialidad: especialidadMap[_especialidadSeleccionada!]!,
                descripcion: _descripcionController.text,
                precioCliente: double.parse(_precioController.text),
                fecha: "${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}",
                franjaHoraria: _franjaSeleccionada!,
              );
            } else if (!isDateSelected) {
              setState(() {}); // para que se vea el error de la fecha
            }
          },
          child: Text('Publicar'),
        ),
      ],
    );
  }
}

void mostrarDialogoConfirmarMateriales(BuildContext context, int idServicio, List<Map<String, dynamic>> materiales) {
  List<bool> llevar = materiales.map((m) => m['llevar'] == 'si').toList();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Confirma los materiales"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < materiales.length; i++)
                    CheckboxListTile(
                      value: llevar[i],
                      title: Text(materiales[i]['nombre_material']),
                      subtitle: Text("Precio: \$${materiales[i]['precio_unitario']} x ${materiales[i]['cantidad']}"),
                      onChanged: (v) {
                        setState(() {
                          llevar[i] = v ?? false;
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text("Que el profesional lleve todo"),
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < llevar.length; i++) {
                          llevar[i] = true;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final materialesEnviar = [
                    for (int i = 0; i < materiales.length; i++)
                      {
                        'id': materiales[i]['id'],
                        'llevar': llevar[i] ? 'si' : 'no',
                      }
                  ];
                  final ok = await ClientMainController().confirmarMaterialesCliente(idServicio, materialesEnviar);
                  if (ok) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Materiales confirmados correctamente")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error al confirmar materiales")),
                    );
                  }
                },
                child: Text("Confirmar selección"),
              ),
            ],
          );
        },
      );
    },
  );
}

String getPrecio(dynamic valor) {
  if (valor == null) return "-";
  if (valor is num) return valor.toStringAsFixed(2);
  return valor.toString();
}
