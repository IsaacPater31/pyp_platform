// lib/models/profesional_model.dart

class ProfesionalModel {
  final int id;
  final String tipoDocumento;
  final String numeroDocumento;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String departamento;
  final String ciudad;
  final String postalCode;
  final String? valoracionPromedio;
  final int serviciosAdquiridos;
  final String fechaCreacion;
  final String estadoSuscripcion;
  final String estadoValidacion;
  final String estadoRegistro;
  final String? fotoPerfil;
  final String? certificadoAntecedentes;
  final String? fotoDocumentoFrontal;
  final String? fotoDocumentoReverso;
  final String? certificadosEspecialidades;
  final String certificacionVerificada;
  final List<String> especialidades; // <-- Nuevo campo

  ProfesionalModel({
    required this.id,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.departamento,
    required this.ciudad,
    required this.postalCode,
    this.valoracionPromedio,
    required this.serviciosAdquiridos,
    required this.fechaCreacion,
    required this.estadoSuscripcion,
    required this.estadoValidacion,
    required this.estadoRegistro,
    this.fotoPerfil,
    this.certificadoAntecedentes,
    this.fotoDocumentoFrontal,
    this.fotoDocumentoReverso,
    this.certificadosEspecialidades,
    required this.certificacionVerificada,
    required this.especialidades,
  });

  factory ProfesionalModel.fromJson(Map<String, dynamic> json) {
    return ProfesionalModel(
      id: json['id'] ?? 0,
      tipoDocumento: json['tipo_documento'] ?? '',
      numeroDocumento: json['numero_documento'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      departamento: json['departamento'] ?? '',
      ciudad: json['ciudad'] ?? '',
      postalCode: json['postal_code'] ?? '',
      valoracionPromedio: json['valoracion_promedio']?.toString(),
      serviciosAdquiridos: json['servicios_adquiridos'] ?? 0,
      fechaCreacion: json['fecha_creacion'] ?? '',
      estadoSuscripcion: json['estado_suscripcion'] ?? '',
      estadoValidacion: json['estado_validacion'] ?? '',
      estadoRegistro: json['estado_registro'] ?? '',
      fotoPerfil: json['foto_perfil'],
      certificadoAntecedentes: json['certificado_antecedentes'],
      fotoDocumentoFrontal: json['foto_documento_frontal'],
      fotoDocumentoReverso: json['foto_documento_reverso'],
      certificadosEspecialidades: json['certificados_especialidades'],
      certificacionVerificada: json['certificacion_verificada'] ?? 'no',
      especialidades: (json['especialidades'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
