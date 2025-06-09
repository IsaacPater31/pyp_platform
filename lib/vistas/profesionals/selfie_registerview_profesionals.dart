// selfie_registerview_profesionals.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pyp_platform/controladores/profesionals/register_profesionals_firststep.dart';
import 'package:pyp_platform/vistas/profesionals/documents_register_profesionals.dart';

class SelfieRegisterViewProfessionals extends StatefulWidget {
  final ProfessionalFirstStepController controller;

  const SelfieRegisterViewProfessionals({super.key, required this.controller});

  @override
  State<SelfieRegisterViewProfessionals> createState() => _SelfieRegisterViewProfessionalsState();
}

class _SelfieRegisterViewProfessionalsState extends State<SelfieRegisterViewProfessionals> {
  File? _selfie;
  bool _isUploading = false;
  bool _isTakingPhoto = false;

  Future<void> _pickSelfie() async {
    setState(() => _isTakingPhoto = true);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() => _isTakingPhoto = false);

    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadSelfie() async {
    if (_selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor toma una selfie.')),
      );
      return;
    }
    setState(() => _isUploading = true);

    final success = await widget.controller.subirSelfie(_selfie!);

    setState(() => _isUploading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.apiMessage), backgroundColor: Colors.green),
      );
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentsRegisterViewProfessionals(controller: widget.controller),
        ),
      );
  }

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
              onTap: _isTakingPhoto ? null : _pickSelfie,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _selfie != null ? FileImage(_selfie!) : null,
                backgroundColor: Colors.grey[300],
                child: _selfie == null && !_isTakingPhoto
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                    : _isTakingPhoto
                        ? const CircularProgressIndicator()
                        : null,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading || _selfie == null ? null : _uploadSelfie,
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
            const SizedBox(height: 24),
            if (widget.controller.selfieUrl != null)
              Column(
                children: [
                  const Text('Vista previa de la selfie subida:'),
                  const SizedBox(height: 8),
                  Image.network(widget.controller.selfieUrl!, height: 120),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
