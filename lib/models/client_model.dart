class ClientModel {
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
  final String detalleDireccion;
  final double? lat;
  final double? lng;
  final double? valoracionPromedio;
  final int serviciosAdquiridos;
  final String fechaCreacion;
  final String estadoSuscripcion;
  final double? valorAcordado; // Nuevo campo

  ClientModel({
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
    required this.detalleDireccion,
    this.lat,
    this.lng,
    this.valoracionPromedio,
    required this.serviciosAdquiridos,
    required this.fechaCreacion,
    required this.estadoSuscripcion,
    this.valorAcordado, // Nuevo campo
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
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
      detalleDireccion: json['detalle_direccion'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      valoracionPromedio: json['valoracion_promedio'] != null
          ? double.tryParse(json['valoracion_promedio'].toString())
          : null,
      serviciosAdquiridos: json['servicios_adquiridos'] ?? 0,
      fechaCreacion: json['fecha_creacion'] ?? '',
      estadoSuscripcion: json['estado_suscripcion'] ?? '',
      valorAcordado: json['valor_acordado'] != null
          ? double.tryParse(json['valor_acordado'].toString())
          : null, // Nuevo campo
    );
  }
}
