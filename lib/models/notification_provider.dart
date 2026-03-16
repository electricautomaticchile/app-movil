import 'package:flutter/material.dart';
import 'notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.leida).length;
  bool get hasUnread => unreadCount > 0;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await NotificationService.getAll();
    } catch (_) {
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // M-05: Rollback en caso de error
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].leida) {
      final original = _notifications[index];
      _notifications[index] = _notifications[index].copyWith(leida: true);
      notifyListeners();
      try {
        await NotificationService.markAsRead(id);
      } catch (_) {
        // Rollback
        _notifications[index] = original;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    final originals = List<AppNotification>.from(_notifications);
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].leida) {
        _notifications[i] = _notifications[i].copyWith(leida: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      try {
        await NotificationService.markAllAsRead();
      } catch (_) {
        _notifications = originals;
        notifyListeners();
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final removed = _notifications.removeAt(index);
    notifyListeners();
    try {
      await NotificationService.delete(id);
    } catch (_) {
      _notifications.insert(index, removed);
      notifyListeners();
    }
  }

  void deleteAll() {
    _notifications.clear();
    notifyListeners();
  }

  void restoreNotification(AppNotification notification, int index) {
    if (index >= 0 && index <= _notifications.length) {
      _notifications.insert(index, notification);
    } else {
      _notifications.add(notification);
    }
    notifyListeners();
  }

  void setNotifications(List<AppNotification> notifications) {
    _notifications = notifications;
    notifyListeners();
  }
}
