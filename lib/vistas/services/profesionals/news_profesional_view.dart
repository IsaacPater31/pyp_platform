import 'package:flutter/material.dart';
import 'page_container.dart';

class NewsProfesionalView extends StatelessWidget {
  const NewsProfesionalView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
