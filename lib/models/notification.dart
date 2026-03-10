// path: lib/models/notification.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Tipos de notificación según el backend: alerta, ticket, sistema, consumo, facturacion
enum NotificationType { alerta, ticket, sistema, consumo, facturacion }

/// Configuración visual para cada tipo de notificación
class NotificationTypeConfig {
  final IconData icon;
  final Color color;

  const NotificationTypeConfig({required this.icon, required this.color});

  static NotificationTypeConfig getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.alerta:
        return const NotificationTypeConfig(
          icon: Icons.warning_amber_rounded,
          color: AppColors.danger,
        );
      case NotificationType.ticket:
        return const NotificationTypeConfig(
          icon: Icons.support_agent_outlined,
          color: AppColors.info,
        );
      case NotificationType.sistema:
        return const NotificationTypeConfig(
          icon: Icons.settings_outlined,
          color: AppColors.mutedForeground,
        );
      case NotificationType.consumo:
        return const NotificationTypeConfig(
          icon: Icons.bolt,
          color: AppColors.primary,
        );
      case NotificationType.facturacion:
        return const NotificationTypeConfig(
          icon: Icons.receipt_long_outlined,
          color: AppColors.success,
        );
    }
  }

  static NotificationType fromString(String tipo) {
    switch (tipo) {
      case 'alerta':
        return NotificationType.alerta;
      case 'ticket':
        return NotificationType.ticket;
      case 'consumo':
        return NotificationType.consumo;
      case 'facturacion':
        return NotificationType.facturacion;
      default:
        return NotificationType.sistema;
    }
  }
}

/// Modelo de notificación alineado con NotificacionModel del backend
class AppNotification {
  final String id;
  final String destinatarioId;
  final String? dispositivoId;
  final String titulo;
  final String mensaje;
  final NotificationType tipo;
  final String? severidad;
  final bool leida;
  final bool resuelta;
  final bool importante;
  final DateTime fechaCreacion;

  const AppNotification({
    required this.id,
    required this.destinatarioId,
    this.dispositivoId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.severidad,
    this.leida = false,
    this.resuelta = false,
    this.importante = false,
    required this.fechaCreacion,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      destinatarioId: json['destinatarioId'] ?? '',
      dispositivoId: json['dispositivoId'],
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: NotificationTypeConfig.fromString(json['tipo'] ?? ''),
      severidad: json['severidad'],
      leida: json['leida'] ?? false,
      resuelta: json['resuelta'] ?? false,
      importante: json['importante'] ?? false,
      fechaCreacion:
          DateTime.tryParse(json['fechaCreacion'] ?? json['createdAt'] ?? '') ??
          DateTime.now(),
    );
  }

  AppNotification copyWith({bool? leida}) {
    return AppNotification(
      id: id,
      destinatarioId: destinatarioId,
      dispositivoId: dispositivoId,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      severidad: severidad,
      leida: leida ?? this.leida,
      resuelta: resuelta,
      importante: importante,
      fechaCreacion: fechaCreacion,
    );
  }

  NotificationTypeConfig get config => NotificationTypeConfig.getConfig(tipo);

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(fechaCreacion);
    if (difference.inMinutes < 1) return 'ahora';
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace ${difference.inHours} h';
    if (difference.inDays < 7) return 'hace ${difference.inDays} d';
    return 'hace ${(difference.inDays / 7).floor()} sem';
  }
}
