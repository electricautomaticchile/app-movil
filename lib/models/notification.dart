// path: lib/models/notification.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Tipos de notificación con configuración visual
enum NotificationType {
  powerOutage,      // Corte de energía crítico
  serviceRestored,  // Servicio restaurado
  billingAvailable, // Facturación disponible
  maintenance,      // Mantenimiento programado
  unusualUsage,     // Consumo inusual
  paymentReceived,  // Pago recibido
}

/// Configuración visual para cada tipo de notificación
class NotificationTypeConfig {
  final IconData icon;
  final Color color;

  const NotificationTypeConfig({
    required this.icon,
    required this.color,
  });

  static NotificationTypeConfig getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.powerOutage:
        return NotificationTypeConfig(
          icon: Icons.warning_amber_rounded,
          color: AppColors.danger,
        );
      case NotificationType.serviceRestored:
        return NotificationTypeConfig(
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        );
      case NotificationType.billingAvailable:
        return NotificationTypeConfig(
          icon: Icons.receipt_long_outlined,
          color: AppColors.info,
        );
      case NotificationType.maintenance:
        return NotificationTypeConfig(
          icon: Icons.build_outlined,
          color: AppColors.primary,
        );
      case NotificationType.unusualUsage:
        return NotificationTypeConfig(
          icon: Icons.trending_up,
          color: AppColors.danger,
        );
      case NotificationType.paymentReceived:
        return NotificationTypeConfig(
          icon: Icons.payments_outlined,
          color: AppColors.success,
        );
    }
  }
}

/// Modelo de notificación
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
  });

  /// Crea una copia con el estado de lectura modificado
  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      description: description,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Devuelve la configuración visual del tipo
  NotificationTypeConfig get config => NotificationTypeConfig.getConfig(type);

  /// Devuelve el tiempo relativo formateado
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} d';
    } else {
      return 'hace ${(difference.inDays / 7).floor()} sem';
    }
  }
}
