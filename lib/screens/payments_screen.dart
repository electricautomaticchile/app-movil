import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/user_provider.dart';
import '../services/invoice_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class PaymentsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PaymentsScreen({super.key, this.onBack});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Invoice> _boletas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final clienteId = context.read<UserProvider>().user?.id ?? '';
      final boletas = await InvoiceService.getByCliente(clienteId);
      if (mounted) {
        setState(() {
          _boletas = boletas;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las boletas';
          _isLoading = false;
        });
      }
    }
  }

  List<Invoice> get _pendientes =>
      _boletas.where((b) => b.estado != 'pagado').toList();

  double get _totalDeuda => _pendientes.fold(0.0, (sum, b) => sum + b.monto);

  Invoice? get _proximaVencer => _pendientes.isEmpty
      ? null
      : (_pendientes
              ..sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion)))
            .first;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
          onPressed: () =>
              widget.onBack != null ? widget.onBack!() : Navigator.pop(context),
        ),
        title: Text(
          'Pagos',
          style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light)
              .copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
            ),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPendingCard(isDark),
                  SizedBox(height: AppSpacing.xxl),
                  _buildPaymentMethods(isDark),
                  SizedBox(height: AppSpacing.xxl),
                  _buildHistory(isDark),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.mutedForeground,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: AppTypography.bodyLight.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildPendingCard(bool isDark) {
    final vence = _proximaVencer;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF9A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Pendiente',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (vence != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'Vence: ${vence.formattedDate}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            _pendientes.isEmpty
                ? '\$0'
                : '\$${_formatNumber(_totalDeuda.toInt())}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          if (_pendientes.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              '${_pendientes.length} boleta(s) pendiente(s)',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _pendientes.isEmpty
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Redirigiendo a pasarela de pago...'),
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white54,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                elevation: 0,
              ),
              child: Text(
                _pendientes.isEmpty ? 'Sin deuda pendiente' : 'Pagar Ahora',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÉTODOS DE PAGO',
          style: AppTypography.label.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.mutedForeground,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _methodCard(
                isDark,
                Icons.account_balance_outlined,
                'Transferencia',
                'Banco Chile',
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _methodCard(
                isDark,
                Icons.credit_card_outlined,
                'Tarjeta',
                'Débito/Crédito',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _methodCard(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Material(
      color: isDark ? AppColors.cardBackgroundDark : Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seleccionado: $title'),
            duration: const Duration(seconds: 1),
          ),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style:
                    (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                        .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistory(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HISTORIAL DE BOLETAS',
              style: AppTypography.label.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${_boletas.length} boleta(s)',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        if (_boletas.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No hay boletas registradas',
                style: AppTypography.bodyLight.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _boletas.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) => _boletaTile(isDark, _boletas[i]),
          ),
      ],
    );
  }

  Widget _boletaTile(bool isDark, Invoice boleta) {
    final status = boleta.statusConfig;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: status.backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: status.color,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boleta.periodo,
                  style:
                      (isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight)
                          .copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  boleta.formattedDate,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                boleta.formattedMonto,
                style:
                    (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                        .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  status.label,
                  style: AppTypography.label.copyWith(
                    color: status.color,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}
