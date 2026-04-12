// path: lib/screens/notifications_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_provider.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
    // Polling cada 30 segundos mientras la pantalla está abierta
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      appBar: _buildAppBar(context, isDark),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState(isDark);
          }
          return _buildNotificationsList(context, provider, isDark);
        },
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
        'Notificaciones',
        style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light).copyWith(
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.notifications.isEmpty) {
              return const SizedBox.shrink();
            }

            return PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.foreground,
              ),
              color: isDark
                  ? AppColors.cardBackgroundDark
                  : AppColors.cardBackgroundLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'read_all':
                    _markAllAsRead(context, provider);
                    break;
                  case 'delete_all':
                    _confirmDeleteAll(context, provider, isDark);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (provider.hasUnread)
                  PopupMenuItem<String>(
                    value: 'read_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          size: 20,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.foreground,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Marcar todas como leídas',
                          style: isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight,
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_sweep_outlined,
                        size: 20,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Eliminar todas',
                        style:
                            (isDark
                                    ? AppTypography.bodyDark
                                    : AppTypography.bodyLight)
                                .copyWith(color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _markAllAsRead(BuildContext context, NotificationProvider provider) {
    provider.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteAll(
    BuildContext context,
    NotificationProvider provider,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.cardBackgroundDark
            : AppColors.cardBackgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          '¿Eliminar todas las notificaciones?',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: isDark ? AppTypography.bodyDark : AppTypography.bodyLight,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              Navigator.pop(context);
              provider.deleteAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todas las notificaciones eliminadas'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    NotificationProvider provider,
    bool isDark,
  ) {
    return ListView.separated(
      padding: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxl),
      itemCount: provider.notifications.length + 1, // +1 para el footer
      separatorBuilder: (context, index) {
        if (index == provider.notifications.length - 1) {
          return const SizedBox.shrink(); // Sin separador antes del footer
        }
        return Divider(
          height: 1,
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          indent:
              AppSpacing.md + 40 + AppSpacing.md, // Alineado con el contenido
        );
      },
      itemBuilder: (context, index) {
        // Footer
        if (index == provider.notifications.length) {
          return _buildFooter(isDark);
        }

        final notification = provider.notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () {
            if (!notification.leida) {
              provider.markAsRead(notification.id);
            }
            // Aquí se podría navegar a un detalle o acción específica
          },
          onMarkAsRead: () {
            provider.markAsRead(notification.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notificación marcada como leída'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          onDismissed: () {
            final deletedNotification = notification;
            final deletedIndex = index;

            provider.deleteNotification(notification.id);

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Notificación eliminada'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Deshacer',
                  textColor: AppColors.primary,
                  onPressed: () {
                    provider.restoreNotification(
                      deletedNotification,
                      deletedIndex,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                : AppColors.mutedForeground.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No tienes notificaciones',
            style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                .copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.mutedForeground,
                ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Te avisaremos cuando haya novedades',
            style: isDark
                ? AppTypography.bodySmallDark
                : AppTypography.bodySmallLight,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.md,
      ),
      child: Center(
        child: Text(
          'Has llegado al final de tus notificaciones',
          style:
              (isDark
                      ? AppTypography.bodySmallDark
                      : AppTypography.bodySmallLight)
                  .copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
