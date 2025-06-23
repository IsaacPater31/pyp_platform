class ServicioModel {
  final int id;
  final int idCliente;
  final int? idProfesional;
  final int idEspecialidad;
  final String descripcion;
  final double precioCliente;
  final double? precioFinal;
  final double? precioAcuerdo; // <-- Agrega esto
  final String fecha;
  final String franjaHoraria;
  final double direccionLat;
  final double direccionLng;
  final String estado;
  final String? pinValidacion;
  final String pagado;
  final String fechaCreacion;
  final String fechaActualizacion;
  final String nombreEspecialidad;
  final String nombreCliente;
  final String ciudadCliente;
  final int yaOferto;
  // --- Nuevos campos ---
  final String telefonoCliente;
  final int reportesCliente;

  ServicioModel({
    required this.id,
    required this.idCliente,
    required this.idProfesional,
    required this.idEspecialidad,
    required this.descripcion,
    required this.precioCliente,
    required this.precioFinal,
    required this.precioAcuerdo, // <-- Agrega esto
    required this.fecha,
    required this.franjaHoraria,
    required this.direccionLat,
    required this.direccionLng,
    required this.estado,
    required this.pinValidacion,
    required this.pagado,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.nombreEspecialidad,
    required this.nombreCliente,
    required this.ciudadCliente,
    required this.yaOferto,
    required this.telefonoCliente,    // Nuevo
    required this.reportesCliente,    // Nuevo
  });

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: int.parse(json['id'].toString()),
      idCliente: int.parse(json['id_cliente'].toString()),
      idProfesional: json['id_profesional'] != null ? int.tryParse(json['id_profesional'].toString()) : null,
      idEspecialidad: int.parse(json['id_especialidad'].toString()),
      descripcion: json['descripcion'] ?? '',
      precioCliente: double.parse(json['precio_cliente'].toString()),
      precioFinal: json['precio_final'] != null ? double.tryParse(json['precio_final'].toString()) : null,
      precioAcuerdo: json['precio_acordado'] != null ? double.tryParse(json['precio_acordado'].toString()) : null, // <-- Agrega esto
      fecha: json['fecha'] ?? '',
      franjaHoraria: json['franja_horaria'] ?? '',
      direccionLat: json['direccion_lat'] != null ? double.parse(json['direccion_lat'].toString()) : 0.0,
      direccionLng: json['direccion_lng'] != null ? double.parse(json['direccion_lng'].toString()) : 0.0,
      estado: json['estado'] ?? '',
      pinValidacion: json['pin_validacion'],
      pagado: json['pagado'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
      fechaActualizacion: json['fecha_actualizacion'] ?? '',
      nombreEspecialidad: json['nombre_especialidad'] ?? '',
      nombreCliente: json['nombre_cliente'] ?? '',
      ciudadCliente: json['ciudad_cliente'] ?? '',
      yaOferto: int.tryParse(json['ya_oferto'].toString()) ?? 0,
      telefonoCliente: json['telefono_cliente'] ?? '',   // Nuevo
      reportesCliente: int.tryParse(json['reportes_cliente'].toString()) ?? 0, // Nuevo
    );
  }
}
