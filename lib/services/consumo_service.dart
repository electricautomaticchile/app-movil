import 'api_service.dart';

class ConsumoResumen {
  final double consumoActual; // kWh
  final double costoActual;
  final double? voltaje;
  final double? corriente;
  final double? potenciaActiva;

  ConsumoResumen({
    required this.consumoActual,
    required this.costoActual,
    this.voltaje,
    this.corriente,
    this.potenciaActiva,
  });

  factory ConsumoResumen.fromJson(Map<String, dynamic> json) {
    final stats = json['estadisticas'] as Map<String, dynamic>? ?? {};
    final ultima = stats['ultimaLectura'] as Map<String, dynamic>?;
    return ConsumoResumen(
      consumoActual: (stats['consumoMensual'] as num?)?.toDouble() ?? 0.0,
      costoActual: (stats['costoMensual'] as num?)?.toDouble() ?? 0.0,
      voltaje: (ultima?['voltage'] as num?)?.toDouble(),
      corriente: (ultima?['current'] as num?)?.toDouble(),
      potenciaActiva: (ultima?['activePower'] as num?)?.toDouble(),
    );
  }
}

class HistorialPunto {
  final String periodo;
  final double energiaTotal;
  final double costoTotal;

  HistorialPunto({
    required this.periodo,
    required this.energiaTotal,
    required this.costoTotal,
  });

  factory HistorialPunto.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] as Map<String, dynamic>?;
    return HistorialPunto(
      periodo: (id?['periodo'] ?? json['periodo'] ?? '') as String,
      energiaTotal: (json['energiaTotal'] as num?)?.toDouble() ?? 0.0,
      costoTotal: (json['costoTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ConsumoService {
  static Future<ConsumoResumen> getResumen() async {
    final response = await ApiService.dio.get('/dashboard/cliente/resumen');
    return ConsumoResumen.fromJson(response.data['data']);
  }

  static Future<List<HistorialPunto>> getHistorial(
    String clienteId,
    String agregacion,
  ) async {
    final response = await ApiService.dio.get(
      '/historial-consumo/$clienteId',
      queryParameters: {'agregacion': agregacion, 'limite': '60'},
    );
    final List<dynamic> items = response.data['data'] ?? [];
    return items.map((e) => HistorialPunto.fromJson(e)).toList();
  }
}
