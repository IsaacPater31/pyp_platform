import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';

class SelfieRegisterViewProfessionals extends StatefulWidget {
  const SelfieRegisterViewProfessionals({super.key});

  @override
  State<SelfieRegisterViewProfessionals> createState() => _SelfieRegisterViewProfessionalsState();
}

class _SelfieRegisterViewProfessionalsState extends State<SelfieRegisterViewProfessionals> with WidgetsBindingObserver {
  File? _selfie;
  bool _isUploading = false;
  bool _isTakingPhoto = false;
  DateTime? _lastBackgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Agregar observador para el ciclo de vida
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Eliminar observador cuando la app se cierre
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastBackgroundTime = DateTime.now(); // Guarda el tiempo en que la app entra en segundo plano
    } else if (state == AppLifecycleState.resumed) {
      final timeInBackground = DateTime.now().difference(_lastBackgroundTime ?? DateTime.now());
      if (timeInBackground.inSeconds > 5) {
        // Si la app estuvo en segundo plano por más de 5 segundos, aseguramos que el estado esté actualizado
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

  // Función para tomar la selfie
  Future<void> _pickSelfie() async {
    setState(() {
      _isTakingPhoto = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (!mounted) return; // Añadido para seguridad

    setState(() {
      _isTakingPhoto = false;  // Terminó el proceso de tomar la foto
    });

    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
      });
    }
  }

  // Función para subir la selfie (simulación)
  void _uploadSelfie() async {
    if (_selfie == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor toma una selfie.')),
      );
      return;
    }

    setState(() => _isUploading = true);  // Empieza a cargar

    await Future.delayed(const Duration(seconds: 2)); // Simulación de subida de selfie

    if (!mounted) return;

    setState(() => _isUploading = false);  // Termina de cargar

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selfie subida correctamente')),
    );

    // Aquí podrías navegar al siguiente paso
    // if (mounted) {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentosRegisterViewProfessionals()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Profesional - Selfie'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1F2937),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Toma una selfie para tu perfil público',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isTakingPhoto ? null : _pickSelfie,  // Deshabilitar si ya está tomando la foto
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _selfie != null ? FileImage(_selfie!) : null,
                backgroundColor: Colors.grey[300],
                child: _selfie == null && !_isTakingPhoto
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                    : _isTakingPhoto
                        ? const CircularProgressIndicator() // Indicador mientras toma la foto
                        : null,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading || _selfie == null ? null : _uploadSelfie, // Deshabilitar el botón mientras sube
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Subir selfie', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
