import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';

class StatsClientView extends StatelessWidget {
  const StatsClientView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
