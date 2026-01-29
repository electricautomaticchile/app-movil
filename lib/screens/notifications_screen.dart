// path: lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_provider.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A) // Gris oscuro, igual que dashboard cliente
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
            if (!provider.hasUnread) return const SizedBox.shrink();
            
            return TextButton(
              onPressed: () {
                provider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todas las notificaciones marcadas como leídas'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Leer todas',
                style: AppTypography.link.copyWith(fontSize: 13),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    NotificationProvider provider,
    bool isDark,
  ) {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xxl,
      ),
      itemCount: provider.notifications.length + 1, // +1 para el footer
      separatorBuilder: (context, index) {
        if (index == provider.notifications.length - 1) {
          return const SizedBox.shrink(); // Sin separador antes del footer
        }
        return Divider(
          height: 1,
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          indent: AppSpacing.md + 40 + AppSpacing.md, // Alineado con el contenido
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
            if (!notification.isRead) {
              provider.markAsRead(notification.id);
            }
            // Aquí se podría navegar a un detalle o acción específica
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
          style: (isDark
                  ? AppTypography.bodySmallDark
                  : AppTypography.bodySmallLight)
              .copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
