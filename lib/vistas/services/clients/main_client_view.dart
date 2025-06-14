import 'package:flutter/material.dart';

class MainClientView extends StatefulWidget {
  const MainClientView({super.key});

  @override
  State<MainClientView> createState() => _MainClientViewState();
}

class _MainClientViewState extends State<MainClientView> {
  int _selectedIndex = 2; // Por defecto en "Nuevo Servicio"

  final List<Widget> _pages = [
    _MyServicesClient(),
    _StatisticsClient(),
    _CreateServiceClient(), // <-- Nuevo Servicio
    _NewsClient(),
    _ProfileClient(),
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
      child: const Icon(Icons.add_box_rounded, size: 32, color: Colors.white), // Icono de "Agregar"
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
              const SizedBox(width: 48),
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

// ----------- Secciones ------------

class _MyServicesClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Mis Servicios",
      child: Center(
        child: Text(
          'Aquí puedes ver tu historial, servicios pendientes y en curso.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StatisticsClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Estadísticas",
      child: Center(
        child: Text(
          'Visualiza estadísticas de tus servicios y actividad.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CreateServiceClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Generar Servicio Nuevo",
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task_rounded, size: 70, color: Color(0xFF1F2937)),
            SizedBox(height: 20),
            Text(
              "Aquí puedes crear y publicar un nuevo servicio.\n\nPróximamente el formulario para ingresar los detalles.",
              style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Aquí podrías abrir el formulario real para crear el servicio.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Aquí se abrirá el formulario de creación de servicio.')),
                );
              },
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
          ],
        ),
      ),
    );
  }
}

class _NewsClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PageContainer(
      title: "Noticias",
      child: Center(
        child: Text(
          'Entérate de lo nuevo en la plataforma.',
          style: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ProfileClient extends StatelessWidget {
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

// --------- Componentes base ---------

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
