// path: lib/screens/facturas_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice_provider.dart';
import '../models/notification_provider.dart';
import '../routes/app_routes.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/month_selector_button.dart';
import '../widgets/invoice_tile.dart';
import '../widgets/icon_circle_button.dart';

class FacturasScreen extends StatelessWidget {
  const FacturasScreen({super.key});

  static const List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril',
    'Mayo', 'Junio', 'Julio', 'Agosto',
    'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
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
            // Año fiscal
            _buildYearSelector(context, isDark),
            SizedBox(height: AppSpacing.xl),

            // Periodo (grid de meses)
            _buildMonthGrid(context, isDark),
            SizedBox(height: AppSpacing.xl),

            // Header de resultados
            _buildResultsHeader(context, isDark),
            SizedBox(height: AppSpacing.md),

            // Lista de facturas
            _buildInvoicesList(context),
            SizedBox(height: AppSpacing.lg),

            // CTA descarga
            _buildDownloadCTA(context, isDark),
            SizedBox(height: AppSpacing.xxl),
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Todas las facturas',
        style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light).copyWith(
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: IconCircleButton(
                icon: Icons.notifications_outlined,
                showBadge: provider.hasUnread,
                onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildYearSelector(BuildContext context, bool isDark) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AÑO FISCAL',
              style: AppTypography.label.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => _showYearPicker(context, provider),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBackgroundDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.selectedYear.toString(),
                      style: (isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showYearPicker(BuildContext context, InvoiceProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Seleccionar año',
                  style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
                ),
              ),
              ...provider.availableYears.map((year) {
                final isSelected = year == provider.selectedYear;
                return ListTile(
                  title: Text(
                    year.toString(),
                    style: (isDark
                            ? AppTypography.bodyDark
                            : AppTypography.bodyLight)
                        .copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    provider.setYear(year);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthGrid(BuildContext context, bool isDark) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERIODO',
              style: AppTypography.label.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                return MonthSelectorButton(
                  label: _months[index],
                  isSelected: provider.selectedMonth == monthNumber,
                  onTap: () => provider.setMonth(monthNumber),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultsHeader(BuildContext context, bool isDark) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${provider.selectedMonthName} ${provider.selectedYear}',
              style: isDark ? AppTypography.h2Dark : AppTypography.h2Light,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 4,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDark
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '${provider.documentCount} Documentos',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoicesList(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        final invoices = provider.filteredInvoices;
        
        if (invoices.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return InvoiceTile(
              invoice: invoices[index],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Detalle de factura: ${invoices[index].number}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : AppColors.mutedForeground.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No hay facturas para este período',
              style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                  .copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCTA(BuildContext context, bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Descargando reporte mensual...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: Icon(
          Icons.download_outlined,
          color: AppColors.primary,
          size: 20,
        ),
        label: Text(
          'Descargar reporte mensual',
          style: AppTypography.link,
        ),
      ),
    );
  }
}
