import 'api_service.dart';
import '../models/notification.dart';

class NotificationService {
  static Future<List<AppNotification>> getAll() async {
    final response = await ApiService.dio.get('/notificaciones');
    final List<dynamic> items = response.data['data'] ?? [];
    return items.map((json) => AppNotification.fromJson(json)).toList();
  }

  static Future<void> markAsRead(String id) async {
    await ApiService.dio.put('/notificaciones/$id', data: {'leida': true});
  }

  static Future<void> delete(String id) async {
    await ApiService.dio.delete('/notificaciones/$id');
  }
}
