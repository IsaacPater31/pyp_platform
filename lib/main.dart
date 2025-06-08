import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pyp_platform/vistas/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: "config.env");
  await dotenv.load(fileName: "config.env");
  print(dotenv.env['API_BASE_URL']);  // Verifica si se está cargando correctamente

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P&P Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
