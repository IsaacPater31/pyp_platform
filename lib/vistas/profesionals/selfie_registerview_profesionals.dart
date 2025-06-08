import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelfieRegisterViewProfessionals extends StatefulWidget {
  const SelfieRegisterViewProfessionals({super.key});

  @override
  State<SelfieRegisterViewProfessionals> createState() => _SelfieRegisterViewProfessionalsState();
}

class _SelfieRegisterViewProfessionalsState extends State<SelfieRegisterViewProfessionals> {
  File? _selfie;
  bool _isUploading = false;

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (!mounted) return; // <- Añadido para seguridad

    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
      });
    }
  }

  void _uploadSelfie() async {
    if (_selfie == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor toma una selfie.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    await Future.delayed(const Duration(seconds: 1)); // Simulación de subida

    if (!mounted) return;

    setState(() => _isUploading = false);

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
              onTap: _pickSelfie,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _selfie != null ? FileImage(_selfie!) : null,
                backgroundColor: Colors.grey[300],
                child: _selfie == null
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadSelfie,
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
