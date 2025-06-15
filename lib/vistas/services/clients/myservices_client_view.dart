import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';

class MyServicesClientView extends StatelessWidget {
  const MyServicesClientView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
