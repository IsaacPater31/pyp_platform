import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyp_platform/controladores/services/profesional_main_controller.dart';
import 'package:pyp_platform/providers/user_provider.dart';
import 'dart:math';
import 'page_container.dart';

class StatsProfesionalView extends StatefulWidget {
  const StatsProfesionalView({super.key});

  @override
  State<StatsProfesionalView> createState() => _StatsProfesionalViewState();
}

class _StatsProfesionalViewState extends State<StatsProfesionalView> {
  late Future<Map<String, dynamic>> _statsFuturo;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _statsFuturo = ProfessionalMainController().obtenerStatsProfesional(userProvider.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: "Estadísticas",
      child: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuturo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay estadísticas disponibles."));
          }
          final stats = snapshot.data!;
          final realizados = stats['servicios_realizados'] ?? 0;
          final estados = stats['estados'] as Map<String, dynamic>? ?? {};
          final comentarios = stats['comentarios'] as List<dynamic>? ?? [];
          final ciudades = stats['ciudades'] as List<dynamic>? ?? [];

          // Progreso hacia el siguiente múltiplo de 25
          final siguienteMultiplo = ((realizados / 25).ceil()) * 25;
          final progreso = realizados == 0 ? 0.0 : (realizados % 25) / 25;

          // Cálculo para el gráfico circular
          final totalEstados = estados.values.fold<int>(0, (a, b) => a + (b as int));
          final estadoColors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.red,
            Colors.brown,
            Colors.indigo,
            Colors.cyan,
            Colors.pink,
          ];
          final estadoKeys = estados.keys.toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Servicios realizados: $realizados", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progreso,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                "Progreso: $realizados / $siguienteMultiplo",
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text("Distribución de servicios por estado", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Center(
                child: totalEstados == 0
                  ? const Text("No hay servicios para mostrar el gráfico.")
                  : SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _PieChartPainter(
                          estados: estados,
                          colors: estadoColors,
                        ),
                        child: Center(
                          child: Text(
                            "$totalEstados\nservicios",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              if (totalEstados > 0)
                Column(
                  children: List.generate(estados.length, (i) {
                    final key = estadoKeys[i];
                    final value = estados[key] as int;
                    final percent = totalEstados == 0 ? 0 : (value / totalEstados * 100);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: estadoColors[i % estadoColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_estadoLabel(key))),
                          Text("$value (${percent.toStringAsFixed(1)}%)"),
                        ],
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 32),
              Text("Comentarios recientes:", style: const TextStyle(fontWeight: FontWeight.bold)),
              if (comentarios.isEmpty)
                const Text("No tienes comentarios recientes."),
              ...comentarios.map((c) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(c['comentario'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text("${c['nombre_cliente'] ?? ''} (${c['ciudad'] ?? ''}) - ${c['fecha']?.toString().substring(0, 10) ?? ''}"),
                  trailing: c['calificacion'] != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            c['calificacion'],
                            (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
                          ),
                        )
                      : null,
                ),
              )),
              const SizedBox(height: 32),
              Text("Ciudades con más servicios:", style: const TextStyle(fontWeight: FontWeight.bold)),
              if (ciudades.isEmpty)
                const Text("No hay ciudades registradas."),
              ...ciudades.map((c) => ListTile(
                leading: const Icon(Icons.location_city, color: Colors.blueGrey),
                title: Text(c['ciudad'] ?? ''),
                trailing: Text("Servicios: ${c['cantidad']}"),
              )),
            ],
          );
        },
      ),
    );
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'finalizado':
        return 'Finalizado';
      case 'en_curso':
        return 'En curso';
      case 'pendiente':
        return 'Pendiente';
      case 'asignado':
        return 'Asignado';
      case 'validando_pin':
        return 'Validando PIN';
      case 'esperando':
        return 'Esperando';
      case 'pendiente_materiales':
        return 'Pend. materiales';
      default:
        return estado[0].toUpperCase() + estado.substring(1).replaceAll('_', ' ');
    }
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, dynamic> estados;
  final List<Color> colors;

  _PieChartPainter({required this.estados, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = estados.values.fold<int>(0, (a, b) => a + (b as int));
    if (total == 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 32;
    double startAngle = -pi / 2;
    int i = 0;
    estados.forEach((key, value) {
      final sweep = (value / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
      i++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
