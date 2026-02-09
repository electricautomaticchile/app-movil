// path: lib/screens/remote_control_screen.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/settings_header.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen>
    with SingleTickerProviderStateMixin {
  bool _isServiceActive = true;
  bool _isProcessing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Historial de acciones simulado
  final List<_ActionHistory> _history = [
    _ActionHistory(
      action: 'Reconexión',
      date: DateTime.now().subtract(const Duration(days: 2)),
      success: true,
    ),
    _ActionHistory(
      action: 'Corte',
      date: DateTime.now().subtract(const Duration(days: 5)),
      success: true,
    ),
    _ActionHistory(
      action: 'Reconexión',
      date: DateTime.now().subtract(const Duration(days: 30)),
      success: true,
    ),
  ];

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleService() async {
    if (_isProcessing) return;

    final bool willDeactivate = _isServiceActive;
    final String action = willDeactivate ? 'corte' : 'reconexión';

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmationDialog(
        title: willDeactivate ? 'Confirmar Corte' : 'Confirmar Reconexión',
        message: willDeactivate
            ? '¿Estás seguro de que deseas solicitar el corte del servicio?'
            : '¿Estás seguro de que deseas solicitar la reconexión del servicio?',
        confirmLabel: willDeactivate ? 'Solicitar Corte' : 'Solicitar Reconexión',
        isDanger: willDeactivate,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isServiceActive = !_isServiceActive;
        _isProcessing = false;
        _history.insert(
          0,
          _ActionHistory(
            action: willDeactivate ? 'Corte' : 'Reconexión',
            date: DateTime.now(),
            success: true,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud de $action procesada correctamente'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : AppColors.backgroundLight,
      appBar: const SettingsHeader(title: 'Control Remoto'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(isDark),
            SizedBox(height: AppSpacing.xl),

            // Power Button
            _buildPowerButton(isDark),
            SizedBox(height: AppSpacing.lg),

            // Warning info
            _buildWarningInfo(isDark),
            SizedBox(height: AppSpacing.xxl),

            // History section
            _buildHistorySection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return AppCard(
      child: Column(
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isServiceActive ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isServiceActive
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.danger.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isServiceActive ? Icons.bolt : Icons.power_off,
                    size: 40,
                    color: _isServiceActive ? AppColors.success : AppColors.danger,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Status text
          Text(
            _isServiceActive ? 'Servicio Activo' : 'Servicio Cortado',
            style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light),
          ),
          SizedBox(height: AppSpacing.sm),

          // Status badge
          StatusBadge(
            label: _isServiceActive ? 'ACTIVO' : 'CORTADO',
            color: _isServiceActive ? AppColors.success : AppColors.danger,
            backgroundColor: _isServiceActive
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.danger.withValues(alpha: 0.1),
          ),
          SizedBox(height: AppSpacing.md),

          // Last update
          Text(
            'Última actualización: Hoy, 10:30 AM',
            style: (isDark ? AppTypography.bodySmallDark : AppTypography.bodySmallLight)
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
    return Center(
      child: Column(
        children: [
          Text(
            _isServiceActive
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

          // Big power button
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
                      : _isServiceActive
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
                    color: (_isServiceActive ? AppColors.danger : AppColors.success)
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.power_settings_new,
                      size: 56,
                      color: Colors.white,
                    ),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          Text(
            _isServiceActive ? 'CORTAR SERVICIO' : 'RECONECTAR SERVICIO',
            style: AppTypography.label.copyWith(
              color: _isServiceActive ? AppColors.danger : AppColors.success,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
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
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 24,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Las solicitudes pueden tardar hasta 24 horas en procesarse. Recibirás una notificación cuando se complete.',
              style: (isDark
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
                style: (isDark
                        ? AppTypography.bodyDark
                        : AppTypography.bodyLight)
                    .copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.mutedForeground,
                ),
              ),
            ),
          )
        else
          ...List.generate(_history.length, (index) {
            final item = _history[index];
            return _HistoryTile(
              action: item.action,
              date: item.date,
              success: item.success,
              isLast: index == _history.length - 1,
            );
          }),
      ],
    );
  }
}

class _ActionHistory {
  final String action;
  final DateTime date;
  final bool success;

  _ActionHistory({
    required this.action,
    required this.date,
    required this.success,
  });
}

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
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else if (diff.inDays < 30) {
      return 'Hace ${(diff.inDays / 7).floor()} semanas';
    } else {
      return 'Hace ${(diff.inDays / 30).floor()} meses';
    }
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
                      (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                          .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(date),
                  style: (isDark
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
      backgroundColor:
          isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight,
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
