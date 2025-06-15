import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';

class ProfileClientView extends StatelessWidget {
  const ProfileClientView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
