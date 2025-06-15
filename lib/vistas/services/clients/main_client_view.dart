import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Necesario para usar el Provider
import 'package:pyp_platform/providers/user_provider.dart'; // <-- Ajusta el path si tu archivo está en otra ruta
import 'myservices_client_view.dart';
import 'stats_client_view.dart';
import 'news_client.dart';
import 'profile_client_view.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';
import 'package:pyp_platform/vistas/services/clients/bottom_menu_icon.dart';

class MainClientView extends StatefulWidget {
  const MainClientView({super.key});

  @override
  State<MainClientView> createState() => _MainClientViewState();
}

class _MainClientViewState extends State<MainClientView> {
  int _selectedIndex = 2; // Por defecto en "Nuevo Servicio"

  // Ofertas simuladas y las que el usuario agregue
  final List<Map<String, Object?>> _ofertas = [
    {
      'profesional': 'Laura Ríos',
      'especialidad': 'Limpieza',
      'valor': 25000,
      'comentario': 'Incluyo materiales.',
    },
    {
      'profesional': 'Superman',
      'especialidad': 'Planchado',
      'valor': 30000,
      'comentario': 'Solo disponible en la tarde.',
    },
  ];

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

  // --- Muestra el formulario de creación de servicio ---
  void _showCreateServiceForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateServiceDialog(
        onServiceCreated: (especialidad, descripcion, precio, observaciones) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Servicio publicado para profesionales!')),
          );
        },
      ),
    );
  }

  // --- Regatear una oferta ---
  void _regatearOferta(int index) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Proponer nuevo precio'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Nuevo valor en pesos'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: Text('Enviar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _ofertas.add({
          'profesional': _ofertas[index]['profesional'],
          'especialidad': _ofertas[index]['especialidad'],
          'valor': result,
          'comentario': '¡Nuevo precio propuesto por el cliente!',
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nuevo precio propuesto al profesional')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ----------- LÍNEAS AGREGADAS PARA MOSTRAR USUARIO Y ROL ----------
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('USUARIO LOGUEADO: ${userProvider.username}');
    print('ROL ACTUAL: ${userProvider.role}');
    print('ID ACTUAL, ${userProvider.userId}');
    // --------------------------------------------------------

    final List<Widget> _pages = [
      const MyServicesClientView(),
      const StatsClientView(),
      _OfertasYCrearServicioClient(
        ofertas: _ofertas,
        onCrearServicio: () => _showCreateServiceForm(context),
        onRegatear: _regatearOferta,
      ),
      const NewsClientView(),
      const ProfileClientView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _pages[_selectedIndex],
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

class _OfertasYCrearServicioClient extends StatelessWidget {
  final List<Map<String, Object?>> ofertas;
  final VoidCallback onCrearServicio;
  final Function(int) onRegatear;

  const _OfertasYCrearServicioClient({
    required this.ofertas,
    required this.onCrearServicio,
    required this.onRegatear,
  });

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Tus Ofertas y Nuevo Servicio",
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: onCrearServicio,
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
              child: ofertas.isEmpty
                  ? Center(
                      child: Text(
                        "No tienes ofertas activas por ahora.",
                        style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: ofertas.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final oferta = ofertas[index];
                        final profesional = oferta['profesional'] as String? ?? "?";
                        final especialidad = oferta['especialidad'] as String? ?? "?";
                        final valor = oferta['valor'] as int? ?? 0;
                        final comentario = oferta['comentario'] as String? ?? "";

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFF1F2937),
                              foregroundColor: Colors.white,
                              child: Text(profesional.isNotEmpty ? profesional[0] : "?"),
                            ),
                            title: Text('$profesional ($especialidad)'),
                            subtitle: Text('Valor ofrecido: \$$valor\n$comentario'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    // Lógica para aceptar la oferta
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.clear, color: Colors.red),
                                  onPressed: () {
                                    // Lógica para rechazar la oferta
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.price_change_rounded, color: Colors.orange),
                                  tooltip: "Regatear",
                                  onPressed: () => onRegatear(index),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navegar al perfil del profesional si lo deseas
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

// --------- Dialog para crear servicio ---------
class CreateServiceDialog extends StatefulWidget {
  final void Function(String especialidad, String descripcion, int precio, String observaciones) onServiceCreated;

  const CreateServiceDialog({
    required this.onServiceCreated,
    super.key,
  });

  @override
  State<CreateServiceDialog> createState() => _CreateServiceDialogState();
}

class _CreateServiceDialogState extends State<CreateServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _especialidadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _obsController = TextEditingController();

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
              TextFormField(
                controller: _especialidadController,
                decoration: InputDecoration(labelText: "Especialidad solicitada (ej. Limpieza)"),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: "Descripción"),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: "Precio propuesto (COP)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? "");
                  return v == null || v <= 0 ? 'Precio válido requerido' : null;
                },
              ),
              TextFormField(
                controller: _obsController,
                decoration: InputDecoration(labelText: "Observaciones (opcional)"),
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
            if (_formKey.currentState!.validate()) {
              widget.onServiceCreated(
                _especialidadController.text,
                _descripcionController.text,
                int.parse(_precioController.text),
                _obsController.text,
              );
            }
          },
          child: Text('Publicar'),
        ),
      ],
    );
  }
}
 