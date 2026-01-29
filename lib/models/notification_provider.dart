// path: lib/models/notification_provider.dart

import 'package:flutter/material.dart';
import 'notification.dart';

/// Provider para el manejo de estado de notificaciones
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];

  NotificationProvider() {
    _loadMockNotifications();
  }

  /// Lista de notificaciones
  List<AppNotification> get notifications => _notifications;

  /// Cantidad de notificaciones no leídas
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Indica si hay notificaciones no leídas
  bool get hasUnread => unreadCount > 0;

  /// Marca una notificación como leída
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leídas
  void markAllAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Carga datos mock para desarrollo
  void _loadMockNotifications() {
    final now = DateTime.now();
    
    _notifications = [
      AppNotification(
        id: '1',
        type: NotificationType.powerOutage,
        title: 'Corte de energía detectado',
        description: 'Se ha detectado una interrupción del servicio en tu zona. Equipos trabajando para restablecer.',
        createdAt: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        type: NotificationType.billingAvailable,
        title: 'Nueva factura disponible',
        description: 'Tu factura de enero 2026 está lista. Monto a pagar: \$45.980',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: '3',
        type: NotificationType.unusualUsage,
        title: 'Consumo inusual detectado',
        description: 'Tu consumo de hoy supera el promedio diario en un 40%. Revisa tus electrodomésticos.',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      AppNotification(
        id: '4',
        type: NotificationType.serviceRestored,
        title: 'Servicio restaurado',
        description: 'El suministro eléctrico ha sido restablecido en tu domicilio.',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '5',
        type: NotificationType.paymentReceived,
        title: 'Pago recibido',
        description: 'Hemos recibido tu pago de \$42.350. Gracias por tu puntualidad.',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: '6',
        type: NotificationType.maintenance,
        title: 'Mantenimiento programado',
        description: 'Se realizará mantenimiento preventivo el 05/02 de 09:00 a 12:00 hrs.',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
    notifyListeners();
  }
}
