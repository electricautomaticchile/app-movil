import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../services/dispositivo_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen>
    with SingleTickerProviderStateMixin {
  EstadoServicio? _estado;
  List<HistorialAccion> _history = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _clienteId => context.read<UserProvider>().user?.id ?? '';

  Future<void> _loadData() async {
    if (_clienteId.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        DispositivoService.getEstadoServicio(_clienteId),
        DispositivoService.getHistorialAcciones(_clienteId),
      ]);
      if (mounted) {
        setState(() {
          _estado = results[0] as EstadoServicio;
          _history = results[1] as List<HistorialAccion>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el estado del servicio';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleService() async {
    if (_isProcessing || _estado == null) return;

    final willDeactivate = _estado!.isActivo;
    final actionLabel = willDeactivate ? 'corte' : 'reconexión';

    // Bloquear reconexión si tiene demasiadas boletas pendientes
    if (!willDeactivate && !_estado!.puedeRestablecer) {
      _showSnack(
        'No puedes restablecer con ${_estado!.boletasPendientes} boletas pendientes',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmationDialog(
        title: willDeactivate ? 'Confirmar Corte' : 'Confirmar Reconexión',
        message: willDeactivate
            ? '¿Estás seguro de que deseas solicitar el corte del servicio?'
            : '¿Estás seguro de que deseas solicitar la reconexión del servicio?',
        confirmLabel: willDeactivate
            ? 'Solicitar Corte'
            : 'Solicitar Reconexión',
        isDanger: willDeactivate,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final nuevoEstado = willDeactivate
          ? await DispositivoService.cortarServicio(_clienteId)
          : await DispositivoService.restablecerServicio(_clienteId);

      if (mounted) {
        setState(() {
          _estado = nuevoEstado;
          _isProcessing = false;
          // Agregar al historial local inmediatamente
          _history.insert(
            0,
            HistorialAccion(
              accion: willDeactivate ? 'Corte' : 'Reconexión',
              fecha: DateTime.now(),
              exitoso: true,
            ),
          );
        });
        _showSnack('Solicitud de $actionLabel procesada correctamente');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
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
          'Control Remoto',
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
          : _buildBody(isDark),
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

  Widget _buildBody(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(isDark),
          SizedBox(height: AppSpacing.xl),
          _buildPowerButton(isDark),
          SizedBox(height: AppSpacing.lg),
          if (_estado!.boletasPendientes > 0) _buildDeudaWarning(isDark),
          if (_estado!.boletasPendientes > 0) SizedBox(height: AppSpacing.lg),
          _buildWarningInfo(isDark),
          SizedBox(height: AppSpacing.xxl),
          _buildHistorySection(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    final isActivo = _estado!.isActivo;
    return AppCard(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) => Transform.scale(
              scale: isActivo ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isActivo
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.danger.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActivo ? Icons.bolt : Icons.power_off,
                  size: 40,
                  color: isActivo ? AppColors.success : AppColors.danger,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            isActivo ? 'Servicio Activo' : 'Servicio Cortado',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
          ),
          SizedBox(height: AppSpacing.sm),
          StatusBadge(
            label: isActivo ? 'ACTIVO' : 'CORTADO',
            color: isActivo ? AppColors.success : AppColors.danger,
            backgroundColor: isActivo
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.danger.withValues(alpha: 0.1),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Última actualización: ${_formatDateTime(_estado!.ultimaActualizacion)}',
            style:
                (isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight)
                    .copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.mutedForeground,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerButton(bool isDark) {
    final isActivo = _estado!.isActivo;
    return Center(
      child: Column(
        children: [
          Text(
            isActivo
                ? 'Toca para solicitar corte'
                : 'Toca para solicitar reconexión',
            style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                .copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.mutedForeground,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _isProcessing ? null : _toggleService,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isProcessing
                      ? [
                          AppColors.mutedForeground,
                          AppColors.mutedForeground.withValues(alpha: 0.7),
                        ]
                      : isActivo
                      ? [
                          AppColors.danger,
                          AppColors.danger.withValues(alpha: 0.8),
                        ]
                      : [
                          AppColors.success,
                          AppColors.success.withValues(alpha: 0.8),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isActivo ? AppColors.danger : AppColors.success)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.power_settings_new,
                      size: 56,
                      color: Colors.white,
                    ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            isActivo ? 'CORTAR SERVICIO' : 'RECONECTAR SERVICIO',
            style: AppTypography.label.copyWith(
              color: isActivo ? AppColors.danger : AppColors.success,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeudaWarning(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${_estado!.boletasPendientes} boleta(s) pendiente(s) — Deuda: \$${_estado!.montoDeuda.toStringAsFixed(0)}',
              style:
                  (isDark
                          ? AppTypography.bodySmallDark
                          : AppTypography.bodySmallLight)
                      .copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningInfo(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 24),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Las solicitudes pueden tardar hasta 24 horas en procesarse. Recibirás una notificación cuando se complete.',
              style:
                  (isDark
                          ? AppTypography.bodySmallDark
                          : AppTypography.bodySmallLight)
                      .copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Acciones',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
        ),
        SizedBox(height: AppSpacing.md),
        if (_history.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No hay acciones registradas',
                style:
                    (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                        .copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.mutedForeground,
                        ),
              ),
            ),
          )
        else
          ...List.generate(_history.length, (i) {
            final item = _history[i];
            return _HistoryTile(
              action: item.accion,
              date: item.fecha,
              success: item.exitoso,
              isLast: i == _history.length - 1,
            );
          }),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── History Tile ──────────────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final String action;
  final DateTime date;
  final bool success;
  final bool isLast;

  const _HistoryTile({
    required this.action,
    required this.date,
    required this.success,
    required this.isLast,
  });

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} semanas';
    return 'Hace ${(diff.inDays / 30).floor()} meses';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReconnection = action == 'Reconexión';

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isReconnection
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              isReconnection ? Icons.power : Icons.power_off,
              color: isReconnection ? AppColors.success : AppColors.danger,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style:
                      (isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight)
                          .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(date),
                  style:
                      (isDark
                              ? AppTypography.bodySmallDark
                              : AppTypography.bodySmallLight)
                          .copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.mutedForeground,
                          ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: success ? 'COMPLETADO' : 'FALLIDO',
            color: success ? AppColors.success : AppColors.danger,
            backgroundColor: success
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.danger.withValues(alpha: 0.1),
            showDot: false,
          ),
        ],
      ),
    );
  }
}

// ── Confirmation Dialog ───────────────────────────────────────────────────────
class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark
          ? AppColors.cardBackgroundDark
          : AppColors.cardBackgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: Text(
        title,
        style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
      ),
      content: Text(
        message,
        style: isDark ? AppTypography.bodyDark : AppTypography.bodyLight,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.mutedForeground,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppColors.danger : AppColors.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
