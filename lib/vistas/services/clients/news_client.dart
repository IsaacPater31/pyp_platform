import 'package:flutter/material.dart';
import 'package:pyp_platform/controladores/services/clientmain_controller.dart';
import 'package:pyp_platform/vistas/services/clients/page_container.dart';

class NewsClientView extends StatefulWidget {
  const NewsClientView({super.key});

  @override
  State<NewsClientView> createState() => _NewsClientViewState();
}

class _NewsClientViewState extends State<NewsClientView> {
  late Future<List<Map<String, dynamic>>> _noticiasFuturo;

  @override
  void initState() {
    super.initState();
    _noticiasFuturo = ClientMainController().obtenerNoticias();
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
            return const Center(child: Text("No hay noticias por ahora."));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: noticias.length,
            itemBuilder: (context, index) {
              final noticia = noticias[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noticia['titulo'] ?? "",
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        noticia['contenido'] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          noticia['fecha_publicacion']?.toString().substring(0, 16) ?? "",
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
