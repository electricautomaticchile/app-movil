import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/invoice_provider.dart';
import '../models/notification_provider.dart';
import '../models/user_provider.dart';
import '../routes/app_routes.dart';
import '../services/pdf_report_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/month_selector_button.dart';
import '../widgets/invoice_tile.dart';
import '../widgets/icon_circle_button.dart';
import '../widgets/status_badge.dart';

class FacturasScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FacturasScreen({super.key, this.onBack});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    // Cargar boletas del backend al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final clienteId = userProvider.user?.id ?? '';
      if (clienteId.isNotEmpty) {
        context.read<InvoiceProvider>().loadInvoices(clienteId);
      }
    });
  }

  static const List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      appBar: _buildAppBar(context, isDark),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de alerta de deuda
                if (provider.deudaResumen != null &&
                    !provider.deudaResumen!.isNormal)
                  _buildAlertBanner(context, isDark, provider),
                if (provider.deudaResumen != null &&
                    !provider.deudaResumen!.isNormal)
                  SizedBox(height: AppSpacing.lg),

                // Año fiscal
                _buildYearSelector(context, isDark),
                SizedBox(height: AppSpacing.xl),

                // Periodo (grid de meses)
                _buildMonthGrid(context, isDark),
                SizedBox(height: AppSpacing.xl),

                // Header de resultados
                _buildResultsHeader(context, isDark),
                SizedBox(height: AppSpacing.md),

                // Lista de boletas
                _buildInvoicesList(context),
                SizedBox(height: AppSpacing.lg),

                // CTA descarga
                _buildDownloadCTA(context, isDark),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, bool isDark, InvoiceProvider provider) {
    final resumen = provider.deudaResumen!;
    Color bannerColor;
    IconData bannerIcon;

    if (resumen.isCorte) {
      bannerColor = AppColors.danger;
      bannerIcon = Icons.power_off;
    } else if (resumen.isCritico) {
      bannerColor = const Color(0xFFE65100);
      bannerIcon = Icons.warning_amber_rounded;
    } else {
      bannerColor = const Color(0xFFF57C00);
      bannerIcon = Icons.info_outline;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: bannerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(bannerIcon, color: bannerColor, size: 22),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resumen.isCorte
                      ? 'Servicio suspendido'
                      : resumen.isCritico
                          ? 'Riesgo de suspensión'
                          : 'Boletas vencidas',
                  style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                      .copyWith(fontWeight: FontWeight.w700, color: bannerColor),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  resumen.mensajeAlerta,
                  style: (isDark ? AppTypography.bodySmallDark : AppTypography.bodySmallLight)
                      .copyWith(color: bannerColor.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
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
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        'Mis Boletas',
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
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
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
                      style:
                          (isDark
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
                    style:
                        (isDark
                                ? AppTypography.bodyDark
                                : AppTypography.bodyLight)
                            .copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
                color: isDark ? AppColors.borderDark : const Color(0xFFF5F5F5),
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return InvoiceTile(
              invoice: invoices[index],
              onTap: () => _showBoletaDetalle(context, invoices[index], isDark),
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
      child: _isGeneratingPdf
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Generando reporte...',
                  style: AppTypography.link.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          : TextButton.icon(
              onPressed: _generatePdfReport,
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

  void _showBoletaDetalle(BuildContext context, Invoice boleta, bool isDark) {
    final status = boleta.statusConfig;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            // Título
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text(boleta.periodo,
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light)),
                const Spacer(),
                StatusBadge(
                  label: status.label,
                  color: status.color,
                  backgroundColor: status.backgroundColor,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            // Detalles
            _detalleRow('Monto', boleta.formattedMonto, isDark, bold: true),
            _detalleRow('Consumo', boleta.formattedConsumo, isDark),
            _detalleRow('Emitida', boleta.formattedDate, isDark),
            if (boleta.fechaVencimiento != null)
              _detalleRow('Vencimiento', boleta.formattedVencimiento, isDark,
                  color: boleta.isVencido ? AppColors.danger : null),
            if (boleta.isPagado && boleta.fechaPago != null)
              _detalleRow('Pagada el', _formatDate(boleta.fechaPago!), isDark,
                  color: AppColors.success),
            SizedBox(height: AppSpacing.xl),
            // Botón PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await PdfReportService.downloadBoletaPdf(
                    context: context,
                    boletaId: boleta.id,
                    periodo: boleta.periodo,
                  );
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Descargar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _detalleRow(String label, String value, bool isDark,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: (isDark ? AppTypography.bodySmallDark : AppTypography.bodySmallLight)
                  .copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.mutedForeground)),
          Text(value,
              style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight).copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color,
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  Future<void> _generatePdfReport() async {
    final provider = context.read<InvoiceProvider>();
    final invoices = provider.filteredInvoices;

    setState(() => _isGeneratingPdf = true);

    try {
      await PdfReportService.generateAndOpenMonthlyReport(
        invoices: invoices,
        year: provider.selectedYear,
        monthName: provider.selectedMonthName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte generado exitosamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el reporte: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }
}
