import 'package:flutter/material.dart';
import 'invoice.dart';
import '../services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  List<Invoice> _invoices = [];
  DeudaResumen? _deudaResumen;
  bool _isLoading = false;
  String? _error;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  List<Invoice> get invoices => _invoices;
  DeudaResumen? get deudaResumen => _deudaResumen;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Invoice> get filteredInvoices {
    return _invoices.where((invoice) {
      return invoice.fechaCreacion.year == _selectedYear &&
          invoice.fechaCreacion.month == _selectedMonth;
    }).toList();
  }

  List<Invoice> get boletasVencidas =>
      _invoices.where((i) => i.isVencido).toList();

  List<Invoice> get boletasPendientes =>
      _invoices.where((i) => i.isPendiente).toList();

  int get documentCount => filteredInvoices.length;

  String get selectedMonthName {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[_selectedMonth - 1];
  }

  List<int> get availableYears {
    final current = DateTime.now().year;
    return [current - 2, current - 1, current, current + 1];
  }

  void setYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      notifyListeners();
    }
  }

  void setMonth(int month) {
    if (_selectedMonth != month && month >= 1 && month <= 12) {
      _selectedMonth = month;
      notifyListeners();
    }
  }

  Future<void> loadInvoices(String clienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        InvoiceService.getByCliente(clienteId),
        InvoiceService.getResumenDeuda(clienteId),
      ]);
      _invoices = results[0] as List<Invoice>;
      _deudaResumen = results[1] as DeudaResumen;
    } catch (e) {
      _error = 'No se pudieron cargar las facturas';
      _invoices = [];
      _deudaResumen = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setInvoices(List<Invoice> invoices) {
    _invoices = invoices;
    notifyListeners();
  }
}
