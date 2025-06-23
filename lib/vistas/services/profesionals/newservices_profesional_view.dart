import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/vistas/services/profesionals/page_container.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'package:pyp_platform/models/servicio_model.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> aceptarServicio(BuildContext context, ServicioModel servicio) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final result = await ProfessionalMainController().aceptarOferta(
      servicio.id,
      userProvider.userId!,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Error al aceptar el servicio.')),
    );
    if (result['success'] == true) {
      setState(() {
        _serviciosFuturo = ProfessionalMainController().obtenerServiciosActivosProfesional(userProvider.userId!);
      });
    }
  }

  void ofertarServicio(BuildContext context, ServicioModel servicio) {
    final TextEditingController precioCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ofertar otro precio'),
        content: TextField(
          controller: precioCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nuevo precio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final double? precio = double.tryParse(precioCtrl.text);
              if (precio == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese un precio válido.')),
                );
                return;
              }
              Navigator.pop(context);
              final result = await ProfessionalMainController().ofertarPrecio(
                servicio.id,
                userProvider.userId!,
                precio,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'] ?? 'Error al ofertar.')),
              );
              if (result['success'] == true) {
                setState(() {
                  _serviciosFuturo = ProfessionalMainController().obtenerServiciosActivosProfesional(userProvider.userId!);
                });
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void mostrarDialogoMateriales(BuildContext context, ServicioModel servicio) {
    showDialog(
      context: context,
      builder: (context) {
        final nombreCtrl = TextEditingController();
        final precioCtrl = TextEditingController();
        final cantidadCtrl = TextEditingController(text: "1");
        final List<Map<String, dynamic>> materiales = [];
        double total = 0;

        void recalcularTotal() {
          total = materiales.fold(0, (sum, mat) => sum + (mat['precio_unitario'] * mat['cantidad']));
        }

        return StatefulBuilder(
          builder: (context, setState) {
            recalcularTotal();
            return AlertDialog(
              title: Text("Lista de materiales"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final mat in materiales)
                      ListTile(
                        title: Text(mat['nombre_material']),
                        subtitle: Text(
                          "Precio: \$${mat['precio_unitario']} x ${mat['cantidad']} = \$${(mat['precio_unitario'] * mat['cantidad']).toStringAsFixed(2)}",
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              materiales.remove(mat);
                            });
                          },
                        ),
                      ),
                    Divider(),
                    TextField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(labelText: "Nombre del material"),
                    ),
                    TextField(
                      controller: precioCtrl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Precio unitario"),
                    ),
                    TextField(
                      controller: cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Cantidad"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text("Añadir material"),
                      onPressed: () {
                        final nombre = nombreCtrl.text.trim();
                        final precio = double.tryParse(precioCtrl.text) ?? 0;
                        final cantidad = int.tryParse(cantidadCtrl.text) ?? 1;
                        if (nombre.isEmpty || precio <= 0 || cantidad <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Completa todos los campos correctamente")),
                          );
                          return;
                        }
                        setState(() {
                          materiales.add({
                            'nombre_material': nombre,
                            'precio_unitario': precio,
                            'cantidad': cantidad,
                          });
                          nombreCtrl.clear();
                          precioCtrl.clear();
                          cantidadCtrl.text = "1";
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Total: \$${total.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cerrar"),
                ),
                ElevatedButton(
                  onPressed: materiales.isEmpty
                      ? null
                      : () async {
                          // Aquí llamas al API para guardar la lista
                          final result = await ProfessionalMainController().enviarListaMateriales(servicio.id, materiales);
                          if (result['success'] == true) {
                            Navigator.pop(context, materiales);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Lista enviada correctamente")),
                            );
                            // Opcional: refresca la lista de servicios
                            setState(() {
                              _serviciosFuturo = ProfessionalMainController().obtenerServiciosActivosProfesional(
                                Provider.of<UserProvider>(context, listen: false).userId!,
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'] ?? "Error al enviar la lista")),
                            );
                          }
                        },
                  child: Text("Enviar lista"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildBotonesAccion({
    required VoidCallback onAceptar,
    required VoidCallback onOferta,
    bool disabled = false,
  }) {
    // Iconos en la esquina inferior derecha del card
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 4, top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniIconButton(
              icon: Icons.check_circle,
              color: Colors.green,
              iconSize: 20,
              btnSize: 38,
              onTap: disabled ? null : onAceptar,
              tooltip: "Aceptar",
            ),
            const SizedBox(width: 8),
            _MiniIconButton(
              icon: Icons.monetization_on,
              color: Colors.orange,
              iconSize: 20,
              btnSize: 38,
              onTap: disabled ? null : onOferta,
              tooltip: "Ofertar",
            ),
          ],
        ),
      ),
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

            final estadosPermitidos = [
              "esperando_profesional",
              "profesional_asignado",
              "pendiente_materiales",
              "en_curso",
              "validando_pin"
            ];
            final nuevos = snapshot.data!
                .where((s) => estadosPermitidos.contains(s.estado))
                .toList();

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
                final esAsignado = servicio.estado == 'profesional_asignado';
                final esEsperando = servicio.estado == 'esperando_profesional';
                final esPendienteMateriales = servicio.estado == 'pendiente_materiales';

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: esAsignado
                      ? Colors.green[50]
                      : esEsperando
                          ? Colors.blue[50]
                          : esPendienteMateriales
                              ? Colors.amber[50]
                              : const Color(0xFFF3F4F6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: esAsignado
                                ? Colors.green[700]
                                : esEsperando
                                    ? Colors.blue[700]
                                    : esPendienteMateriales
                                        ? Colors.amber[700]
                                        : const Color(0xFF1F2937),
                            foregroundColor: Colors.white,
                            child: esAsignado
                                ? Icon(Icons.verified_user, color: Colors.white)
                                : esEsperando
                                    ? Icon(Icons.fiber_new, color: Colors.white)
                                    : esPendienteMateriales
                                        ? Icon(Icons.hourglass_top, color: Colors.white)
                                        : Text(servicio.nombreCliente.isNotEmpty ? servicio.nombreCliente[0] : "?"),
                          ),
                          title: Text(
                            '${servicio.nombreCliente} (${servicio.nombreEspecialidad})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                servicio.estado == 'en_curso'
                                    ? 'Precio final: \$${servicio.precioFinal ?? servicio.precioAcuerdo ?? servicio.precioCliente}'
                                    : servicio.estado == 'pendiente_materiales'
                                        ? 'Precio acordado: \$${servicio.precioFinal ?? servicio.precioAcuerdo ?? servicio.precioCliente}'
                                        : 'Pago: \$${servicio.precioCliente}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  esAsignado
                                      ? Icon(Icons.verified_user, color: Colors.green, size: 18)
                                      : esEsperando
                                          ? Icon(Icons.fiber_new, color: Colors.blue, size: 18)
                                          : esPendienteMateriales
                                              ? Icon(Icons.hourglass_top, color: Colors.amber, size: 18)
                                              : Icon(Icons.hourglass_top, color: Colors.amber, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    esAsignado
                                        ? "Has sido elegido"
                                        : esEsperando
                                            ? "Nuevo servicio"
                                            : esPendienteMateriales
                                                ? "Pendiente materiales"
                                                : servicio.estado.replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: esAsignado
                                          ? Colors.green[800]
                                          : esEsperando
                                              ? Colors.blue[800]
                                              : esPendienteMateriales
                                                  ? Colors.amber[800]
                                                  : Color(0xFF1F2937),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              if (esPendienteMateriales) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Esperando los materiales requeridos",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.amber[800],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
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
                                      Text(
                                        (servicio.estado == 'en_curso' || servicio.estado == 'pendiente_materiales')
                                            ? 'Precio final: \$${servicio.precioFinal ?? servicio.precioCliente}'
                                            : 'Pago: \$${servicio.precioCliente}',
                                      ),
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
                        const SizedBox(height: 12),
                        if (esAsignado) ...[
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.playlist_add, color: Colors.white),
                              label: const Text("Generar lista de materiales"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                mostrarDialogoMateriales(context, servicio);
                              },
                            ),
                          ),
                        ] else if (esEsperando) ...[
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8, bottom: 4, top: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _MiniIconButton(
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                    iconSize: 20,
                                    btnSize: 38,
                                    onTap: () => aceptarServicio(context, servicio),
                                    tooltip: "Aceptar",
                                  ),
                                  const SizedBox(width: 8),
                                  _MiniIconButton(
                                    icon: Icons.monetization_on,
                                    color: Colors.orange,
                                    iconSize: 20,
                                    btnSize: 38,
                                    onTap: () => ofertarServicio(context, servicio),
                                    tooltip: "Ofertar",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else if (servicio.estado == 'validando_pin') ...[
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1F2937).withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF1F2937), width: 1.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Validar PIN del cliente",
                                  style: TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Controlador para el PIN
                                Builder(
                                  builder: (context) {
                                    final pinController = TextEditingController();
                                    return Column(
                                      children: [
                                        TextField(
                                          controller: pinController,
                                          decoration: InputDecoration(
                                            labelText: "Ingresa el PIN que te da el cliente",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.vpn_key, color: Colors.white),
                                          label: Text("Validar PIN"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF1F2937),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () async {
                                            final pin = pinController.text.trim();
                                            if (pin.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Por favor ingresa el PIN.")),
                                              );
                                              return;
                                            }
                                            final result = await ProfessionalMainController().validarPinServicio(servicio.id, pin);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(result['message'] ?? 'Error al validar el PIN.')),
                                            );
                                            if (result['success'] == true) {
                                              // Opcional: refresca la lista de servicios
                                              setState(() {
                                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                                _serviciosFuturo = ProfessionalMainController().obtenerServiciosActivosProfesional(userProvider.userId!);
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.phone, color: Colors.green, size: 26),
                                      tooltip: "Llamar",
                                      onPressed: () {
                                        final tel = servicio.telefonoCliente.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (tel.isNotEmpty) {
                                          launchUrl(Uri.parse('tel:+57$tel'));
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.chat, color: Colors.teal, size: 26),
                                      tooltip: "WhatsApp",
                                      onPressed: () {
                                        final tel = servicio.telefonoCliente.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (tel.isNotEmpty) {
                                          launchUrl(Uri.parse('https://wa.me/57$tel'));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.inventory_2, color: Colors.white),
                                  label: Text("Ver materiales a llevar"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1F2937),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    final materiales = await ProfessionalMainController().obtenerMaterialesServicio(servicio.id);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final materialesLlevar = materiales.where((m) => m['llevar'] == 'si').toList();
                                        return AlertDialog(
                                          title: Text("Materiales que debes llevar"),
                                          content: materialesLlevar.isEmpty
                                              ? Text("No hay materiales que debas llevar para este servicio.")
                                              : Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: materialesLlevar.map<Widget>((mat) => ListTile(
                                                    title: Text(mat['nombre_material'] ?? ''),
                                                    subtitle: Text("Cantidad: ${mat['cantidad']}  |  Precio: \$${mat['precio_unitario']}"),
                                                  )).toList(),
                                                ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text("Cerrar"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else if (servicio.estado == 'en_curso') ...[
                          const SizedBox(height: 12),
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.check_circle, color: Colors.white),
                              label: Text("Finalizar servicio"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1F2937),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                mostrarDialogoFinalizarServicio(context, servicio);
                              },
                            ),
                          ),
                        ],
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

  void mostrarDialogoFinalizarServicio(BuildContext context, ServicioModel servicio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("¿El cliente pagó el servicio?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Precio a cobrar: \$${servicio.precioFinal ?? servicio.precioCliente}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937)),
              ),
              SizedBox(height: 16),
              Text(
                "Selecciona una opción según el estado del pago.",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // No pagado
                final result = await ProfessionalMainController().finalizarServicio(servicio.id, pagado: false);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? "Servicio marcado como impago.")),
                );
                if (result['success'] == true) {
                  // Refresca la lista
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  (context as Element).markNeedsBuild();
                }
              },
              child: Text("No pagado", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Pagado
                final result = await ProfessionalMainController().finalizarServicio(servicio.id, pagado: true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? "Servicio finalizado.")),
                );
                if (result['success'] == true) {
                  // Refresca la lista
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  (context as Element).markNeedsBuild();
                }
              },
              child: Text("Pagado"),
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Ink(
        decoration: ShapeDecoration(
          color: isDisabled ? Colors.grey[400] : color.withAlpha(92),
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