// path: lib/models/meter.dart

import 'meter_config.dart';
import 'reading.dart';

class Meter {
  final String tipo;
  final String estado;
  final String clienteAsignado;
  final String ubicacion;
  final MeterConfig configuracion;
  final DateTime fechaCreacion;
  final String numeroDispositivo;
  final String nombre;
  final bool activo;
  final String clienteId;
  final String empresaId;
  final DateTime fechaActualizacion;
  final Reading ultimaLectura;

  Meter({
    required this.tipo,
    required this.estado,
    required this.clienteAsignado,
    required this.ubicacion,
    required this.configuracion,
    required this.fechaCreacion,
    required this.numeroDispositivo,
    required this.nombre,
    required this.activo,
    required this.clienteId,
    required this.empresaId,
    required this.fechaActualizacion,
    required this.ultimaLectura,
  });

  factory Meter.fromJson(Map<String, dynamic> json) {
    return Meter(
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
      clienteAsignado: json['clienteAsignado'] as String,
      ubicacion: json['ubicacion'] as String,
      configuracion: MeterConfig.fromJson(
        json['configuracion'] as Map<String, dynamic>,
      ),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      numeroDispositivo: json['numeroDispositivo'] as String,
      nombre: json['nombre'] as String,
      activo: json['activo'] as bool,
      clienteId: json['clienteId'] as String,
      empresaId: json['empresaId'] as String,
      fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
      ultimaLectura: Reading.fromJson(
        json['ultimaLectura'] as Map<String, dynamic>,
      ),
    );
  }
}
