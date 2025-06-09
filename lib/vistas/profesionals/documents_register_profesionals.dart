import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pyp_platform/controladores/profesionals/register_profesionals_firststep.dart';
import 'package:pyp_platform/vistas/profesionals/registerfailed_profesionals.dart';
import 'package:pyp_platform/vistas/profesionals/registersuccess_profesionals.dart'; 

class DocumentsRegisterViewProfessionals extends StatefulWidget {
  final ProfessionalFirstStepController controller;

  const DocumentsRegisterViewProfessionals({super.key, required this.controller});

  @override
  State<DocumentsRegisterViewProfessionals> createState() => _DocumentsRegisterViewProfessionalsState();
}

class _DocumentsRegisterViewProfessionalsState extends State<DocumentsRegisterViewProfessionals> {
  File? _frontDocument;
  File? _reverseDocument;
  File? _certificatesPdf;
  File? _antecedentesPdf;

  bool _isUploading = false;

  // Seleccionar foto (frontal/reverso)
  Future<void> _pickDocumentPhoto(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (pickedFile != null) {
      final ext = pickedFile.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        setState(() {
          if (isFront) {
            _frontDocument = File(pickedFile.path);
          } else {
            _reverseDocument = File(pickedFile.path);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo se permiten imágenes (jpg, jpeg, png, webp).')),
        );
      }
    }
  }

  // Seleccionar PDF de certificados (opcional)
  Future<void> _pickCertificatesPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _certificatesPdf = File(result.files.single.path!));
    }
  }

  // Seleccionar PDF de antecedentes (obligatorio)
  Future<void> _pickAntecedentesPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _antecedentesPdf = File(result.files.single.path!));
    }
  }

  Future<void> _uploadDocuments() async {
  if (_frontDocument == null || _reverseDocument == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes subir ambas fotos del documento de identidad.')),
    );
    return;
  }
  if (_antecedentesPdf == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes subir el certificado de antecedentes (PDF).')),
    );
    return;
  }

  setState(() => _isUploading = true);

  // SUBIDA FRONTAL
  final frontalOK = await widget.controller.subirDocumentoFrontal(_frontDocument!);
  if (!frontalOK) {
    setState(() => _isUploading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterFailedProfessionalsView(
          errorMessage: widget.controller.apiMessage,
        ),
      ),
    );
    return;
  }

  // SUBIDA REVERSO
  final reversoOK = await widget.controller.subirDocumentoReverso(_reverseDocument!);
  if (!reversoOK) {
    setState(() => _isUploading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterFailedProfessionalsView(
          errorMessage: widget.controller.apiMessage,
        ),
      ),
    );
    return;
  }

  // SUBIDA CERTIFICADOS (opcional)
  if (_certificatesPdf != null) {
    final certOK = await widget.controller.subirCertificadosEspecialidad(_certificatesPdf!);
    if (!certOK) {
      setState(() => _isUploading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterFailedProfessionalsView(
            errorMessage: widget.controller.apiMessage,
          ),
        ),
      );
      return;
    }
  }

  // SUBIDA ANTECEDENTES
  final antOK = await widget.controller.subirAntecedentes(_antecedentesPdf!);
  if (!antOK) {
    setState(() => _isUploading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterFailedProfessionalsView(
          errorMessage: widget.controller.apiMessage,
        ),
      ),
    );
    return;
  }

  // LLAMADA AL API PARA MARCAR COMO COMPLETO
  final registroCompletoOK = await widget.controller.marcarRegistroCompleto();
  setState(() => _isUploading = false);

  if (!registroCompletoOK) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterFailedProfessionalsView(
          errorMessage: widget.controller.apiMessage,
        ),
      ),
    );
    return;
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const RegisterSuccessProfessionalsView()),
    (route) => false,
  );
}


  Widget _filePreview(File? file, {bool isPdf = false, String? label}) {
    if (file == null) {
      return Text('No seleccionado', style: TextStyle(color: Colors.grey[700]));
    }
    if (isPdf) {
      return Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          Flexible(child: Text(label ?? 'PDF seleccionado', overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Image.file(file, width: 120, height: 80, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro - Documentos'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1F2937),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Documento de identidad (Frontal)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _filePreview(_frontDocument),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar foto frontal'),
                onPressed: () => _pickDocumentPhoto(true),
              ),
              const Divider(height: 32),

              const Text('Documento de identidad (Reverso)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _filePreview(_reverseDocument),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar foto reverso'),
                onPressed: () => _pickDocumentPhoto(false),
              ),
              const Divider(height: 32),

              const Text('Certificados de especialidad (PDF, opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _filePreview(_certificatesPdf, isPdf: true, label: _certificatesPdf?.path.split('/').last ?? ''),
              TextButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Subir certificados (PDF)'),
                onPressed: _pickCertificatesPdf,
              ),
              const Divider(height: 32),

              const Text('Certificado de antecedentes (PDF, obligatorio)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _filePreview(_antecedentesPdf, isPdf: true, label: _antecedentesPdf?.path.split('/').last ?? ''),
              TextButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Subir certificado de antecedentes (PDF)'),
                onPressed: _pickAntecedentesPdf,
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadDocuments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Subir documentos y finalizar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
