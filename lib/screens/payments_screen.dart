// path: lib/screens/payments_screen.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class PaymentsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const PaymentsScreen({super.key, this.onBack});

  // Mock data for payment history
  static final List<_PaymentItem> _paymentHistory = [
    _PaymentItem(
      date: '15 Ene 2026',
      amount: 45250,
      status: 'Pagado',
      method: 'Transferencia',
    ),
    _PaymentItem(
      date: '15 Dic 2025',
      amount: 52100,
      status: 'Pagado',
      method: 'Tarjeta',
    ),
    _PaymentItem(
      date: '15 Nov 2025',
      amount: 48750,
      status: 'Pagado',
      method: 'Transferencia',
    ),
    _PaymentItem(
      date: '15 Oct 2025',
      amount: 41300,
      status: 'Pagado',
      method: 'Tarjeta',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPendingPaymentCard(context, isDark),
            SizedBox(height: AppSpacing.xxl),
            _buildPaymentMethodsSection(context, isDark),
            SizedBox(height: AppSpacing.xxl),
            _buildHistorySection(context, isDark),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        'Pagos',
        style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light).copyWith(
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPendingPaymentCard(BuildContext context, bool isDark) {
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: const Text(
                  'Vence: 28 Feb',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          const Text(
            '\$58.450',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirigiendo a pasarela de pago...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pagar Ahora',
                style: TextStyle(
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

  Widget _buildPaymentMethodsSection(BuildContext context, bool isDark) {
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
              child: _buildPaymentMethodCard(
                context,
                isDark,
                icon: Icons.account_balance_outlined,
                title: 'Transferencia',
                subtitle: 'Banco Chile',
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildPaymentMethodCard(
                context,
                isDark,
                icon: Icons.credit_card_outlined,
                title: 'Tarjeta',
                subtitle: 'Débito/Crédito',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: isDark ? AppColors.cardBackgroundDark : Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seleccionado: $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
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
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
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

  Widget _buildHistorySection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HISTORIAL DE PAGOS',
              style: AppTypography.label.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${_paymentHistory.length} pagos',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _paymentHistory.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return _buildPaymentHistoryTile(context, isDark, _paymentHistory[index]);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTile(
    BuildContext context,
    bool isDark,
    _PaymentItem payment,
  ) {
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
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.date,
                  style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  payment.method,
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
                '\$${_formatNumber(payment.amount)}',
                style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  payment.status,
                  style: AppTypography.label.copyWith(
                    color: AppColors.success,
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _PaymentItem {
  final String date;
  final int amount;
  final String status;
  final String method;

  _PaymentItem({
    required this.date,
    required this.amount,
    required this.status,
    required this.method,
  });
}
