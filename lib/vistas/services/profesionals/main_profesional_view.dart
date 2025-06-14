import 'package:flutter/material.dart';

class MainProfesionalView extends StatefulWidget {
  const MainProfesionalView({super.key});

  @override
  State<MainProfesionalView> createState() => _MainProfesionalViewState();
}

class _MainProfesionalViewState extends State<MainProfesionalView> {
  int _selectedIndex = 2; // Por defecto: Servicios Nuevos (centro)

  // Páginas del menú inferior
  final List<Widget> _pages = [
    _MisServiciosProfesional(),
    _EstadisticasProfesional(),
    _ServiciosNuevosProfesional(),
    _NoticiasProfesional(),
    _PerfilProfesional(),
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
      child: const Icon(Icons.fiber_new_rounded, size: 32, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _BottomMenuIcon(
                icon: Icons.assignment_outlined,
                label: 'Mis Servicios',
                selected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _BottomMenuIcon(
                icon: Icons.bar_chart_outlined,
                label: 'Estadísticas',
                selected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48), // Espacio para el botón central
              _BottomMenuIcon(
                icon: Icons.newspaper_outlined,
                label: 'Noticias',
                selected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
              _BottomMenuIcon(
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

// -------- Secciones para el profesional --------

class _MisServiciosProfesional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Mis Servicios",
      child: Center(
        child: Text(
          'Aquí puedes ver tus servicios realizados, pendientes y en curso.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EstadisticasProfesional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Estadísticas",
      child: Center(
        child: Text(
          'Visualiza tus estadísticas: servicios realizados, horas trabajadas, etc.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ServiciosNuevosProfesional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí puedes agregar tu lógica de FutureBuilder/StreamBuilder para los servicios nuevos
    return _PageContainer(
      title: "Servicios Nuevos",
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: 6, // Puedes reemplazar esto con la cantidad real de servicios
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) => Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.miscellaneous_services_rounded, color: Color(0xFF1F2937)),
            title: Text(
              'Servicio #${index + 1}',
              style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Tipo de servicio - Área geográfica\nDuración estimada: 2 horas'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF1F2937)),
            onTap: () {
              // Aquí puedes mostrar el detalle del servicio
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Detalle del Servicio'),
                  content: Text('Aquí van los detalles completos del servicio #${index + 1}'),
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
        ),
      ),
    );
  }
}

class _NoticiasProfesional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Noticias",
      child: Center(
        child: Text(
          'Mantente informado con las noticias de la plataforma.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PerfilProfesional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Perfil",
      child: Center(
        child: Text(
          'Aquí puedes editar tus datos y configuraciones.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ------ Componentes base ------

class _PageContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _PageContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BottomMenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomMenuIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Color(0xFF1F2937) : Color(0xFF6B7280), size: 26),
            Text(
              label,
              style: TextStyle(
                color: selected ? Color(0xFF1F2937) : Color(0xFF6B7280),
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
