import 'package:flutter/material.dart';
import 'bottom_menu_icon.dart';
import 'myservices_profesional_view.dart';
import 'stats_profesional_view.dart';
import 'newservices_profesional_view.dart';
import 'news_profesional_view.dart';
import 'profile_profesional_view.dart';

class MainProfesionalView extends StatefulWidget {
  const MainProfesionalView({super.key});

  @override
  State<MainProfesionalView> createState() => _MainProfesionalViewState();
}

class _MainProfesionalViewState extends State<MainProfesionalView> {
  int _selectedIndex = 2; // Página central

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCentralIcon() {
    return FloatingActionButton(
      onPressed: () => _onItemTapped(2),
      backgroundColor: const Color(0xFF1F2937),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: const Icon(Icons.fiber_new_rounded, size: 32, color: Colors.white),
    );
  }

  final List<Widget> _pages = const [
    MyServicesProfesionalView(),
    StatsProfesionalView(),
    NewServicesProfesionalView(),
    NewsProfesionalView(),
    ProfileProfesionalView(),
  ];

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
