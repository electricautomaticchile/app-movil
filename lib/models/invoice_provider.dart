// path: lib/models/invoice_provider.dart

import 'package:flutter/material.dart';
import 'invoice.dart';

/// Provider para el manejo de estado de facturas
class InvoiceProvider extends ChangeNotifier {
  int _selectedYear = 2026;
  int _selectedMonth = 8; // Agosto por defecto
  List<Invoice> _invoices = [];

  InvoiceProvider() {
    _loadMockInvoices();
  }

  /// Año fiscal seleccionado
  int get selectedYear => _selectedYear;

  /// Mes seleccionado (1-12)
  int get selectedMonth => _selectedMonth;

  /// Todas las facturas
  List<Invoice> get invoices => _invoices;

  /// Facturas filtradas por año y mes seleccionados
  List<Invoice> get filteredInvoices {
    return _invoices.where((invoice) {
      return invoice.date.year == _selectedYear &&
             invoice.date.month == _selectedMonth;
    }).toList();
  }

  /// Cantidad de facturas filtradas
  int get documentCount => filteredInvoices.length;

  /// Nombre del mes seleccionado
  String get selectedMonthName {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[_selectedMonth - 1];
  }

  /// Años disponibles
  List<int> get availableYears => [2024, 2025, 2026, 2027];

  /// Cambiar año fiscal
  void setYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      notifyListeners();
    }
  }

  /// Cambiar mes
  void setMonth(int month) {
    if (_selectedMonth != month && month >= 1 && month <= 12) {
      _selectedMonth = month;
      notifyListeners();
    }
  }

  /// Carga datos mock para desarrollo
  void _loadMockInvoices() {
    _invoices = [
      // Agosto 2026
      Invoice(
        id: '1',
        number: 'INV-00823',
        type: InvoiceType.electricity,
        description: 'Electricidad - Casa Central',
        date: DateTime(2026, 8, 15),
        amount: 45200,
        status: InvoiceStatus.paid,
      ),
      Invoice(
        id: '2',
        number: 'INV-00824',
        type: InvoiceType.maintenance,
        description: 'Mantenimiento Mensual',
        date: DateTime(2026, 8, 10),
        amount: 15800,
        status: InvoiceStatus.overdue,
      ),
      Invoice(
        id: '3',
        number: 'INV-00825',
        type: InvoiceType.water,
        description: 'Agua - Casa Central',
        date: DateTime(2026, 8, 5),
        amount: 12500,
        status: InvoiceStatus.paid,
      ),
      // Julio 2026
      Invoice(
        id: '4',
        number: 'INV-00810',
        type: InvoiceType.electricity,
        description: 'Electricidad - Casa Central',
        date: DateTime(2026, 7, 15),
        amount: 42800,
        status: InvoiceStatus.paid,
      ),
      Invoice(
        id: '5',
        number: 'INV-00811',
        type: InvoiceType.water,
        description: 'Agua - Casa Central',
        date: DateTime(2026, 7, 5),
        amount: 11200,
        status: InvoiceStatus.paid,
      ),
      // Junio 2026
      Invoice(
        id: '6',
        number: 'INV-00798',
        type: InvoiceType.electricity,
        description: 'Electricidad - Casa Central',
        date: DateTime(2026, 6, 15),
        amount: 38500,
        status: InvoiceStatus.paid,
      ),
    ];
    notifyListeners();
  }
}
