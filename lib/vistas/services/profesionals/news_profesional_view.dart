import 'package:flutter/material.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'page_container.dart';

class NewsProfesionalView extends StatefulWidget {
  const NewsProfesionalView({super.key});

  @override
  State<NewsProfesionalView> createState() => _NewsProfesionalViewState();
}

class _NewsProfesionalViewState extends State<NewsProfesionalView> {
  late Future<List<Map<String, dynamic>>> _noticiasFuturo;

  @override
  void initState() {
    super.initState();
    _noticiasFuturo = ProfessionalMainController().obtenerNoticias();
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Noticias",
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _noticiasFuturo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final noticias = snapshot.data ?? [];
          if (noticias.isEmpty) {
            return const Center(child: Text(
              "No hay noticias disponibles.",
              style: TextStyle(fontSize: 16),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: noticias.length,
            itemBuilder: (context, i) {
              final noticia = noticias[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    noticia['titulo'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      noticia['contenido'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Puedes poner aquí la imagen si la tienes, como:
                  // leading: noticia['imagen'] != null ? Image.network(noticia['imagen']) : null,
                  // pero si no la usas, déjalo sin leading.
                ),
              );
            },
          );
        },
      ),
    );
  }
}
