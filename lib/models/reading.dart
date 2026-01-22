// path: lib/models/reading.dart

class Reading {
  final double cost;
  final DateTime timestamp;
  final double voltage;
  final double current;
  final double activePower;
  final double energy;

  Reading({
    required this.cost,
    required this.timestamp,
    required this.voltage,
    required this.current,
    required this.activePower,
    required this.energy,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      cost: (json['cost'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      activePower: (json['activePower'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
    );
  }
}
