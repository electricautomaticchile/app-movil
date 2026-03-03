import 'api_service.dart';
import '../models/invoice.dart';

class InvoiceService {
  static Future<List<Invoice>> getByCliente(String clienteId) async {
    final response = await ApiService.dio.get('/boletas/cliente/$clienteId');

    final List<dynamic> items = response.data['data'] ?? [];
    return items.map((json) => Invoice.fromJson(json)).toList();
  }
}
