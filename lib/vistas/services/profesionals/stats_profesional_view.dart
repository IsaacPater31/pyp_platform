import 'package:flutter/material.dart';
import 'page_container.dart';

class StatsProfesionalView extends StatelessWidget {
  const StatsProfesionalView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
