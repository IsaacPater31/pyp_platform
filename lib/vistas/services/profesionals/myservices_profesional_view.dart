import 'package:flutter/material.dart';
import 'page_container.dart';

class MyServicesProfesionalView extends StatelessWidget {
  const MyServicesProfesionalView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
