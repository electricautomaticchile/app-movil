import 'package:dio/dio.dart';
import 'api_service.dart';

class EstadoServicio {
  final String clienteId;
  final String estadoServicio; // "activo" | "cortado"
  final int boletasPendientes;
  final double montoDeuda;
  final bool puedeRestablecer;
  final String motivoCorte;
  final DateTime ultimaActualizacion;

  EstadoServicio({
    required this.clienteId,
    required this.estadoServicio,
    required this.boletasPendientes,
    required this.montoDeuda,
    required this.puedeRestablecer,
    required this.motivoCorte,
    required this.ultimaActualizacion,
  });

  bool get isActivo => estadoServicio == 'activo';

  factory EstadoServicio.fromJson(Map<String, dynamic> json) {
    return EstadoServicio(
      clienteId: json['clienteId']?.toString() ?? '',
      estadoServicio: json['estadoServicio'] ?? 'activo',
      boletasPendientes: (json['boletasPendientes'] as num?)?.toInt() ?? 0,
      montoDeuda: (json['montoDeuda'] as num?)?.toDouble() ?? 0.0,
      puedeRestablecer: json['puedeRestablecer'] ?? true,
      motivoCorte: json['motivoCorte'] ?? '',
      ultimaActualizacion:
          DateTime.tryParse(json['ultimaActualizacion'] ?? '') ??
          DateTime.now(),
    );
  }
}

class HistorialAccion {
  final String accion; // "Corte" | "Reconexión"
  final DateTime fecha;
  final bool exitoso;

  HistorialAccion({
    required this.accion,
    required this.fecha,
    required this.exitoso,
  });
}

class DispositivoService {
  /// GET /servicio-electrico/:clienteId
  static Future<EstadoServicio> getEstadoServicio(String clienteId) async {
    final response = await ApiService.dio.get('/servicio-electrico/$clienteId');
    return EstadoServicio.fromJson(response.data['data']);
  }

  /// POST /servicio-electrico/:clienteId/cortar
  static Future<EstadoServicio> cortarServicio(String clienteId) async {
    final response = await ApiService.dio.post(
      '/servicio-electrico/$clienteId/cortar',
    );
    return EstadoServicio.fromJson(response.data['data']);
  }

  /// POST /servicio-electrico/:clienteId/restablecer
  static Future<EstadoServicio> restablecerServicio(String clienteId) async {
    final response = await ApiService.dio.post(
      '/servicio-electrico/$clienteId/restablecer',
    );
    if (response.data['success'] == false) {
      throw Exception(
        response.data['error'] ?? 'No se pudo restablecer el servicio',
      );
    }
    return EstadoServicio.fromJson(response.data['data']);
  }

  /// GET /historial-consumo/:clienteId — reutiliza el endpoint existente
  /// para construir el historial de acciones desde boletas/lecturas
  /// Por ahora retorna lista vacía si no hay endpoint dedicado
  static Future<List<HistorialAccion>> getHistorialAcciones(
    String clienteId,
  ) async {
    try {
      final response = await ApiService.dio.get(
        '/historial-consumo/$clienteId',
        queryParameters: {'agregacion': 'mes', 'limite': '10'},
      );
      // El backend no tiene endpoint de historial de cortes aún,
      // retornamos lista vacía para no mostrar datos falsos
      final _ = response.data;
      return [];
    } on DioException {
      return [];
    }
  }
}
