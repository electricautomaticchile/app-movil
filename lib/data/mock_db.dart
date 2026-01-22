// path: lib/data/mock_db.dart

import 'dart:math' as math;
import '../models/meter.dart';

class MockDB {
  // Datos del medidor según especificación
  static final Map<String, dynamic> _meterData = {
    "tipo": "arduino_uno",
    "estado": "activo",
    "clienteAsignado": "69532a6334f12c52ce80bd9d",
    "ubicacion": "C.Alcalde Galleguillos 1951",
    "configuracion": {
      "potenciaMaxima": 2.5,
      "tarifaKwh": 150.0,
      "voltajeNominal": 5.0,
      "corrienteMaxima": 0.5,
    },
    "fechaCreacion": "2026-01-09T22:51:07.516+00:00",
    "numeroDispositivo": "7649815-6",
    "nombre": "Arduino 7649815-6",
    "activo": true,
    "clienteId": "69532a6334f12c52ce80bd9d",
    "empresaId": "000000000000000000000000",
    "fechaActualizacion": "2026-01-09T23:36:30.132+00:00",
    "ultimaLectura": {
      "cost": 12.82,
      "timestamp": "2026-01-10T00:24:53.086+00:00",
      "voltage": 220.0,
      "current": 0.5,
      "activePower": 110.0,
      "energy": 0.0855,
    },
  };

  static Meter getMeter() {
    return Meter.fromJson(_meterData);
  }

  /// Genera una serie determinística de 12 puntos basándose en el valor real
  /// El último punto coincide con ultimaLectura.energy (0.0855)
  /// Usa una función sinusoidal para variación suave y determinística
  static List<double> generateEnergySeries() {
    final meter = getMeter();
    final targetValue = meter.ultimaLectura.energy; // 0.0855
    const int points = 12;

    List<double> series = [];

    // Generamos valores usando una función sinusoidal
    // que termina en el valor real
    for (int i = 0; i < points; i++) {
      // Usamos seno para crear variación suave
      // Fase: de 0 a π para crear una curva creciente
      double phase = (i / (points - 1)) * math.pi;

      // Variación: ±15% del valor target
      double variation = math.sin(phase * 2) * targetValue * 0.15;

      // Tendencia creciente hacia el valor real
      double trend =
          targetValue * 0.7 + (targetValue * 0.3 * (i / (points - 1)));

      double value = trend + variation;

      // Asegurar que el último punto sea exactamente el valor real
      if (i == points - 1) {
        value = targetValue;
      }

      // Redondear a 4 decimales
      series.add(double.parse(value.toStringAsFixed(4)));
    }

    return series;
  }

  /// Calcula el porcentaje de cambio entre el último y penúltimo valor
  static double calculatePercentChange(List<double> series) {
    if (series.length < 2) return 0.0;

    double current = series.last;
    double previous = series[series.length - 2];

    if (previous == 0) return 0.0;

    double percent = ((current - previous) / previous) * 100;
    return double.parse(percent.toStringAsFixed(1));
  }

  /// Genera serie para mes anterior (simulada con valores mayores)
  static List<double> generatePreviousMonthSeries() {
    final currentSeries = generateEnergySeries();
    // Incrementar ~30% para simular mes anterior con más consumo
    return currentSeries
        .map((v) => double.parse((v * 1.3).toStringAsFixed(4)))
        .toList();
  }
}
