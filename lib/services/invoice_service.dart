import 'api_service.dart';
import '../models/invoice.dart';

class DeudaResumen {
  final int boletasPendientes;
  final int boletasVencidas;
  final double montoTotal;
  final double montoVencido;
  final DateTime? proximoVencimiento;
  final String nivelAlerta; // "normal", "advertencia", "critico", "corte"

  DeudaResumen({
    required this.boletasPendientes,
    required this.boletasVencidas,
    required this.montoTotal,
    required this.montoVencido,
    required this.nivelAlerta,
    this.proximoVencimiento,
  });

  factory DeudaResumen.fromJson(Map<String, dynamic> json) {
    return DeudaResumen(
      boletasPendientes: (json['boletasPendientes'] as num?)?.toInt() ?? 0,
      boletasVencidas: (json['boletasVencidas'] as num?)?.toInt() ?? 0,
      montoTotal: (json['montoTotal'] as num?)?.toDouble() ?? 0.0,
      montoVencido: (json['montoVencido'] as num?)?.toDouble() ?? 0.0,
      nivelAlerta: json['nivelAlerta']?.toString() ?? 'normal',
      proximoVencimiento: json['proximoVencimiento'] != null
          ? DateTime.tryParse(json['proximoVencimiento'].toString())
          : null,
    );
  }

  bool get isNormal => nivelAlerta == 'normal';
  bool get isAdvertencia => nivelAlerta == 'advertencia';
  bool get isCritico => nivelAlerta == 'critico';
  bool get isCorte => nivelAlerta == 'corte';

  String get mensajeAlerta {
    switch (nivelAlerta) {
      case 'advertencia':
        return 'Tienes $boletasVencidas boleta(s) vencida(s). Paga para evitar la suspensión del servicio.';
      case 'critico':
        return '⚠️ Tienes $boletasVencidas boletas vencidas. Tu suministro será suspendido si no pagas antes del próximo vencimiento.';
      case 'corte':
        return '🔴 Tu suministro fue suspendido por $boletasVencidas boletas vencidas. Paga las boletas pendientes para restablecer el servicio.';
      default:
        return '';
    }
  }
}

class InvoiceService {
  /// Obtener boletas del cliente
  static Future<List<Invoice>> getByCliente(String clienteId) async {
    final response = await ApiService.dio.get('/boletas/cliente/$clienteId');
    final List<dynamic> items = response.data['data'] ?? [];
    return items.map((json) => Invoice.fromJson(json)).toList();
  }

  /// Obtener resumen de deuda del cliente
  static Future<DeudaResumen> getResumenDeuda(String clienteId) async {
    final response = await ApiService.dio.get(
      '/boletas/cliente/$clienteId/resumen-deuda',
    );
    return DeudaResumen.fromJson(response.data['data']);
  }

  /// Confirmar pago de una boleta (operador o webhook)
  static Future<void> confirmarPago(String boletaId) async {
    await ApiService.dio.post('/boletas/$boletaId/confirmar-pago');
  }
}
