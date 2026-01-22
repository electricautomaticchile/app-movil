// path: lib/models/meter_config.dart

class MeterConfig {
  final double potenciaMaxima;
  final double tarifaKwh;
  final double voltajeNominal;
  final double corrienteMaxima;

  MeterConfig({
    required this.potenciaMaxima,
    required this.tarifaKwh,
    required this.voltajeNominal,
    required this.corrienteMaxima,
  });

  factory MeterConfig.fromJson(Map<String, dynamic> json) {
    return MeterConfig(
      potenciaMaxima: (json['potenciaMaxima'] as num).toDouble(),
      tarifaKwh: (json['tarifaKwh'] as num).toDouble(),
      voltajeNominal: (json['voltajeNominal'] as num).toDouble(),
      corrienteMaxima: (json['corrienteMaxima'] as num).toDouble(),
    );
  }
}
