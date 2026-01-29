// path: lib/models/invoice.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Estado de la factura
enum InvoiceStatus { paid, overdue, pending }

/// Tipo de factura/servicio
enum InvoiceType { electricity, maintenance, water }

/// Configuración visual para cada tipo de factura
class InvoiceTypeConfig {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const InvoiceTypeConfig({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  static InvoiceTypeConfig getConfig(InvoiceType type) {
    switch (type) {
      case InvoiceType.electricity:
        return InvoiceTypeConfig(
          icon: Icons.receipt_long_outlined,
          color: AppColors.info,
          backgroundColor: const Color(0xFFE8F4FD),
        );
      case InvoiceType.maintenance:
        return InvoiceTypeConfig(
          icon: Icons.bolt,
          color: AppColors.primary,
          backgroundColor: const Color(0xFFFFF3E0),
        );
      case InvoiceType.water:
        return InvoiceTypeConfig(
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF00BCD4),
          backgroundColor: const Color(0xFFE0F7FA),
        );
    }
  }
}

/// Configuración visual para cada estado de factura
class InvoiceStatusConfig {
  final String label;
  final Color color;
  final Color backgroundColor;

  const InvoiceStatusConfig({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  static InvoiceStatusConfig getConfig(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return InvoiceStatusConfig(
          label: 'PAGADO',
          color: AppColors.success,
          backgroundColor: const Color(0xFFE8F5E9),
        );
      case InvoiceStatus.overdue:
        return InvoiceStatusConfig(
          label: 'VENCIDO',
          color: AppColors.danger,
          backgroundColor: const Color(0xFFFFEBEE),
        );
      case InvoiceStatus.pending:
        return InvoiceStatusConfig(
          label: 'PENDIENTE',
          color: AppColors.primary,
          backgroundColor: const Color(0xFFFFF3E0),
        );
    }
  }
}

/// Modelo de factura
class Invoice {
  final String id;
  final String number;
  final InvoiceType type;
  final String description;
  final DateTime date;
  final double amount;
  final InvoiceStatus status;

  const Invoice({
    required this.id,
    required this.number,
    required this.type,
    required this.description,
    required this.date,
    required this.amount,
    required this.status,
  });

  /// Configuración visual del tipo
  InvoiceTypeConfig get typeConfig => InvoiceTypeConfig.getConfig(type);

  /// Configuración visual del estado
  InvoiceStatusConfig get statusConfig => InvoiceStatusConfig.getConfig(status);

  /// Fecha formateada
  String get formattedDate {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  /// Monto formateado
  String get formattedAmount {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '\$$formatted';
  }
}
