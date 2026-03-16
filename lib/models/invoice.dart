// path: lib/models/invoice.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Estados según el backend: pagado, pendiente, vencido
class InvoiceStatusConfig {
  final String label;
  final Color color;
  final Color backgroundColor;

  const InvoiceStatusConfig({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  static InvoiceStatusConfig fromEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return const InvoiceStatusConfig(
          label: 'PAGADO',
          color: AppColors.success,
          backgroundColor: Color(0xFFE8F5E9),
        );
      case 'vencido':
        return const InvoiceStatusConfig(
          label: 'VENCIDO',
          color: AppColors.danger,
          backgroundColor: Color(0xFFFFEBEE),
        );
      default: // pendiente
        return const InvoiceStatusConfig(
          label: 'PENDIENTE',
          color: AppColors.primary,
          backgroundColor: Color(0xFFFFF3E0),
        );
    }
  }
}

/// Modelo de boleta alineado con BoletaModel del backend
class Invoice {
  final String id;
  final String clienteId;
  final double monto;
  final String periodo;
  final String estado;
  final DateTime fechaCreacion;
  final DateTime? fechaPago;

  const Invoice({
    required this.id,
    required this.clienteId,
    required this.monto,
    required this.periodo,
    required this.estado,
    required this.fechaCreacion,
    this.fechaPago,
  });

  // M-01: Parsing seguro con valores por defecto
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      clienteId: json['clienteId']?.toString() ?? '',
      monto: _parseDouble(json['monto']),
      periodo: json['periodo']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'pendiente',
      fechaCreacion: _parseDate(json['fechaCreacion']) ?? DateTime.now(),
      fechaPago: _parseDate(json['fechaPago']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  InvoiceStatusConfig get statusConfig =>
      InvoiceStatusConfig.fromEstado(estado);

  String get formattedDate {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${fechaCreacion.day} ${months[fechaCreacion.month - 1]}, ${fechaCreacion.year}';
  }

  String get formattedMonto {
    final formatted = monto
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '\$$formatted';
  }

  // Ícono siempre de electricidad ya que la app es solo para clientes eléctricos
  IconData get icon => Icons.receipt_long_outlined;
  Color get iconColor => AppColors.info;
  Color get iconBackground => const Color(0xFFE8F4FD);
}
