import 'api_service.dart';

class EmpresaDashboardData {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> clientes;
  final List<Map<String, dynamic>> dispositivos;
  final List<Map<String, dynamic>> alertas;
  final List<Map<String, dynamic>> tickets;
  final List<Map<String, dynamic>> usuarios;
  final List<Map<String, dynamic>> tarifas;
  final Map<String, dynamic> health;
  final DateTime fetchedAt;

  const EmpresaDashboardData({
    required this.stats,
    required this.clientes,
    required this.dispositivos,
    required this.alertas,
    required this.tickets,
    required this.usuarios,
    required this.tarifas,
    required this.health,
    required this.fetchedAt,
  });
}

class EmpresaApiService {
  static Future<EmpresaDashboardData> loadDashboard() async {
    final stats = await getStats();

    final results = await Future.wait<dynamic>([
      _safe(() => getClientes(limit: 30), <Map<String, dynamic>>[]),
      _safe(() => getDispositivos(limit: 30), <Map<String, dynamic>>[]),
      _safe(() => getAlertas(), <Map<String, dynamic>>[]),
      _safe(() => getTickets(limit: 30), <Map<String, dynamic>>[]),
      _safe(() => getUsuarios(limit: 30), <Map<String, dynamic>>[]),
      _safe(() => getTarifas(limit: 30), <Map<String, dynamic>>[]),
      _safe(getHealth, <String, dynamic>{}),
    ]);

    return EmpresaDashboardData(
      stats: stats,
      clientes: List<Map<String, dynamic>>.from(results[0] as List),
      dispositivos: List<Map<String, dynamic>>.from(results[1] as List),
      alertas: List<Map<String, dynamic>>.from(results[2] as List),
      tickets: List<Map<String, dynamic>>.from(results[3] as List),
      usuarios: List<Map<String, dynamic>>.from(results[4] as List),
      tarifas: List<Map<String, dynamic>>.from(results[5] as List),
      health: Map<String, dynamic>.from(results[6] as Map),
      fetchedAt: DateTime.now(),
    );
  }

  static Future<Map<String, dynamic>> getStats() async {
    final response = await ApiService.dio.get('/dashboard/estadisticas');
    return _asMap(_unwrap(response.data));
  }

  static Future<List<Map<String, dynamic>>> getClientes({
    int limit = 50,
  }) async {
    final response = await ApiService.dio.get(
      '/clientes',
      queryParameters: {'limit': limit},
    );
    return _asList(_unwrap(response.data));
  }

  static Future<List<Map<String, dynamic>>> getDispositivos({
    int limit = 50,
  }) async {
    final response = await ApiService.dio.get(
      '/dispositivos',
      queryParameters: {'limit': limit},
    );
    return _asList(_unwrap(response.data));
  }

  static Future<List<Map<String, dynamic>>> getAlertas() async {
    final response = await ApiService.dio.get('/notificaciones');
    return _asList(_unwrap(response.data));
  }

  static Future<List<Map<String, dynamic>>> getTickets({int limit = 50}) async {
    final response = await ApiService.dio.get(
      '/tickets',
      queryParameters: {'limit': limit},
    );
    return _asList(_unwrap(response.data));
  }

  static Future<List<Map<String, dynamic>>> getUsuarios({
    int limit = 50,
  }) async {
    final response = await ApiService.dio.get(
      '/usuarios-empresa',
      queryParameters: {'limit': limit},
    );
    return _asList(_unwrap(response.data));
  }

  static Future<List<Map<String, dynamic>>> getTarifas({int limit = 50}) async {
    final response = await ApiService.dio.get(
      '/tarifas',
      queryParameters: {'limit': limit},
    );
    return _asList(_unwrap(response.data));
  }

  static Future<Map<String, dynamic>> getHealth() async {
    final response = await ApiService.dio.get('/admin/health');
    return _asMap(_unwrap(response.data));
  }

  static Future<T> _safe<T>(Future<T> Function() loader, T fallback) async {
    try {
      return await loader();
    } catch (_) {
      return fallback;
    }
  }

  static dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (value is Map) {
      for (final key in const [
        'data',
        'items',
        'results',
        'clientes',
        'dispositivos',
        'notificaciones',
        'tickets',
        'usuarios',
        'tarifas',
      ]) {
        final nested = value[key];
        if (nested is List) return _asList(nested);
      }
    }

    return <Map<String, dynamic>>[];
  }
}
