// path: lib/models/meter.dart

import 'reading.dart';

class Meter {
  final String id;
  final String tipo;
  final String estado;
  final String clienteId;
  final String direccion;
  final Map<String, dynamic> configuracion;
  final DateTime fechaCreacion;
  final String numeroDispositivo;
  final String nombre;
  final bool activo;
  final Reading? ultimaLectura;
  final DateTime? fechaActualizacion;

  Meter({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.clienteId,
    required this.direccion,
    required this.configuracion,
    required this.fechaCreacion,
    required this.numeroDispositivo,
    required this.nombre,
    required this.activo,
    this.ultimaLectura,
    this.fechaActualizacion,
  });

  factory Meter.fromJson(Map<String, dynamic> json) {
    return Meter(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      estado: json['estado'] ?? '',
      clienteId: json['clienteId'] ?? '',
      direccion: json['direccion'] ?? '',
      configuracion: (json['configuracion'] as Map<String, dynamic>?) ?? {},
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      numeroDispositivo: json['numeroDispositivo'] ?? '',
      nombre: json['nombre'] ?? '',
      activo: json['activo'] ?? false,
      ultimaLectura: json['ultimaLectura'] != null
          ? Reading.fromJson(json['ultimaLectura'] as Map<String, dynamic>)
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'] as String)
          : null,
    );
  }
}
