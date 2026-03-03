import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../services/consumo_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/metric_card.dart';
import '../widgets/historical_card.dart';

class MiConsumoScreen extends StatefulWidget {
  const MiConsumoScreen({super.key});

  @override
  State<MiConsumoScreen> createState() => _MiConsumoScreenState();
}

class _MiConsumoScreenState extends State<MiConsumoScreen> {
  bool _isLoading = true;
  String? _error;

  ConsumoResumen? _resumen;
  List<HistorialPunto> _historialMesActual = [];
  List<HistorialPunto> _historialMesAnterior = [];

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

      final results = await Future.wait([
        ConsumoService.getResumen(),
        ConsumoService.getHistorial(clienteId, 'dia'),
      ]);

      final resumen = results[0] as ConsumoResumen;
      final historial = results[1] as List<HistorialPunto>;

      // Separar mes actual y mes anterior
      final now = DateTime.now();
      final mesActualStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final mesAnterior = DateTime(now.year, now.month - 1);
      final mesAnteriorStr =
          '${mesAnterior.year}-${mesAnterior.month.toString().padLeft(2, '0')}';

      setState(() {
        _resumen = resumen;
        _historialMesActual = historial
            .where((p) => p.periodo.startsWith(mesActualStr))
            .toList();
        _historialMesAnterior = historial
            .where((p) => p.periodo.startsWith(mesAnteriorStr))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el consumo';
        _isLoading = false;
      });
    }
  }

  List<double> _toChartData(List<HistorialPunto> puntos) {
    if (puntos.isEmpty) return List.filled(7, 0.0);
    return puntos.map((p) => p.energiaTotal).toList();
  }

  double _totalKwh(List<HistorialPunto> puntos) {
    if (puntos.isEmpty) return 0;
    return puntos.fold(0.0, (sum, p) => sum + p.energiaTotal);
  }

  double _percentChange() {
    final actual = _totalKwh(_historialMesActual);
    final anterior = _totalKwh(_historialMesAnterior);
    if (anterior == 0) return 0;
    return double.parse(
      (((actual - anterior) / anterior) * 100).toStringAsFixed(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A1A1A)
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mi Consumo',
          style: isDark ? AppTypography.h2Dark : AppTypography.h2Light,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
            ),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildContent(isDark),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_outlined,
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

  Widget _buildContent(bool isDark) {
    final resumen = _resumen!;
    final consumoKwh = resumen.consumoActual;
    final pct = _percentChange();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitorea tu consumo de energía en tiempo real',
              style: isDark ? AppTypography.bodyDark : AppTypography.bodyLight,
            ),
            SizedBox(height: AppSpacing.xxl),

            // Consumo actual
            MetricCard(
              label: 'Consumo Actual',
              value: consumoKwh.toStringAsFixed(2),
              unit: 'kWh',
              percentChange: pct.toString(),
              chartData: _toChartData(_historialMesActual),
            ),

            // Métricas eléctricas si hay última lectura
            if (resumen.voltaje != null) ...[
              SizedBox(height: AppSpacing.lg),
              _buildElectricMetrics(isDark, resumen),
            ],

            SizedBox(height: AppSpacing.xxl),

            Text(
              'Comparativa Mensual',
              style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
            ),
            SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: HistoricalCard(
                    label: 'Mes Anterior',
                    value: _totalKwh(_historialMesAnterior).toStringAsFixed(1),
                    unit: 'kWh',
                    borderColor: AppColors.danger,
                    chartData: _toChartData(_historialMesAnterior),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HistoricalCard(
                    label: 'Mes Actual',
                    value: _totalKwh(_historialMesActual).toStringAsFixed(1),
                    unit: 'kWh',
                    borderColor: AppColors.success,
                    chartData: _toChartData(_historialMesActual),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.xxl),
            _buildInfoCard(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildElectricMetrics(bool isDark, ConsumoResumen resumen) {
    return Row(
      children: [
        if (resumen.voltaje != null)
          Expanded(
            child: _metricChip(
              isDark,
              '${resumen.voltaje!.toStringAsFixed(1)} V',
              'Voltaje',
              Icons.electric_bolt,
            ),
          ),
        SizedBox(width: AppSpacing.sm),
        if (resumen.corriente != null)
          Expanded(
            child: _metricChip(
              isDark,
              '${resumen.corriente!.toStringAsFixed(2)} A',
              'Corriente',
              Icons.electrical_services,
            ),
          ),
        SizedBox(width: AppSpacing.sm),
        if (resumen.potenciaActiva != null)
          Expanded(
            child: _metricChip(
              isDark,
              '${resumen.potenciaActiva!.toStringAsFixed(1)} W',
              'Potencia',
              Icons.power,
            ),
          ),
      ],
    );
  }

  Widget _metricChip(bool isDark, String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.mutedForeground,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Consejos de Ahorro',
                style:
                    (isDark
                            ? AppTypography.bodyLargeDark
                            : AppTypography.bodyLargeLight)
                        .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildTip(isDark, 'Desconecta los dispositivos que no uses'),
          SizedBox(height: AppSpacing.sm),
          _buildTip(isDark, 'Usa electrodomésticos en horas de menor consumo'),
          SizedBox(height: AppSpacing.sm),
          _buildTip(isDark, 'Cambia a iluminación LED para ahorrar hasta 80%'),
        ],
      ),
    );
  }

  Widget _buildTip(bool isDark, String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle, size: 16, color: AppColors.success),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            tip,
            style: isDark
                ? AppTypography.bodySmallDark
                : AppTypography.bodySmallLight,
          ),
        ),
      ],
    );
  }
}
