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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is String)
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      cost: _parseDouble(json['cost']),
      timestamp: _parseDate(json['timestamp']),
      voltage: _parseDouble(json['voltage']),
      current: _parseDouble(json['current']),
      activePower: _parseDouble(json['activePower']),
      energy: _parseDouble(json['energy']),
    );
  }
}
