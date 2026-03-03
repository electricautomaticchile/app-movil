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

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].leida) {
      _notifications[index] = _notifications[index].copyWith(leida: true);
      notifyListeners();
      try {
        await NotificationService.markAsRead(id);
      } catch (_) {}
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].leida) {
        _notifications[i] = _notifications[i].copyWith(leida: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    try {
      await NotificationService.delete(id);
    } catch (_) {}
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
