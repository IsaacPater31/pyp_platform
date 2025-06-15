import 'package:flutter/material.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';

class NewsClientView extends StatelessWidget {
  const NewsClientView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
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
