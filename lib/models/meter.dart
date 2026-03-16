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

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is String)
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory Meter.fromJson(Map<String, dynamic> json) {
    return Meter(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      estado: json['estado'] ?? '',
      clienteId: json['clienteId'] ?? '',
      direccion: json['direccion'] ?? '',
      configuracion: (json['configuracion'] as Map<String, dynamic>?) ?? {},
      fechaCreacion: _parseDate(json['fechaCreacion']),
      numeroDispositivo: json['numeroDispositivo'] ?? '',
      nombre: json['nombre'] ?? '',
      activo: json['activo'] ?? false,
      ultimaLectura:
          json['ultimaLectura'] != null &&
              json['ultimaLectura'] is Map<String, dynamic>
          ? Reading.fromJson(json['ultimaLectura'] as Map<String, dynamic>)
          : null,
      fechaActualizacion: _parseDate(json['fechaActualizacion']),
    );
  }
}
