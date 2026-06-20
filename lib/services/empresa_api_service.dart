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
  final List<String> failedModules;
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
    this.failedModules = const [],
    required this.fetchedAt,
  });
}

class EmpresaApiService {
  static Future<EmpresaDashboardData> loadDashboard() async {
    final stats = await getStats();
    final failedModules = <String>[];

    final results = await Future.wait<dynamic>([
      _safe(
        'clientes',
        () => getClientes(limit: 30),
        <Map<String, dynamic>>[],
        failedModules,
      ),
      _safe(
        'dispositivos',
        () => getDispositivos(limit: 30),
        <Map<String, dynamic>>[],
        failedModules,
      ),
      _safe(
        'alertas',
        () => getAlertas(),
        <Map<String, dynamic>>[],
        failedModules,
      ),
      _safe(
        'soporte',
        () => getTickets(limit: 30),
        <Map<String, dynamic>>[],
        failedModules,
      ),
      _safe(
        'usuarios',
        () => getUsuarios(limit: 30),
        <Map<String, dynamic>>[],
        failedModules,
      ),
      _safe(
        'tarifas',
        () => getTarifas(limit: 30),
        <Map<String, dynamic>>[],
        failedModules,
      ),
      _safe('health', getHealth, <String, dynamic>{}, failedModules),
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
      failedModules: failedModules,
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

  static Future<T> _safe<T>(
    String module,
    Future<T> Function() loader,
    T fallback,
    List<String> failedModules,
  ) async {
    try {
      return await loader();
    } catch (_) {
      failedModules.add(module);
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
