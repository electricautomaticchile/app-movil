// path: lib/widgets/energy_line_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EnergyLineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double fillOpacity;
  final double height;

  const EnergyLineChart({
    super.key,
    required this.values,
    required this.color,
    this.fillOpacity = 0.1,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height);
    }

    // Encontrar min y max para escalar
    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);

    // Agregar padding al rango
    double range = maxY - minY;
    double paddedMin = minY - (range * 0.1);
    double paddedMax = maxY + (range * 0.1);

    // Si todos los valores son iguales, agregar rango artificial
    if (range == 0) {
      paddedMin = minY * 0.9;
      paddedMax = maxY * 1.1;
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: paddedMin,
          maxY: paddedMax,
          lineBarsData: [
            LineChartBarData(
              spots: values
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: fillOpacity),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
