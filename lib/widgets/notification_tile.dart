// path: lib/widgets/notification_tile.dart

import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Widget configurable para mostrar una notificación individual
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;
  final VoidCallback? onMarkAsRead;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismissed,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = notification.config;
    
    // Opacidad reducida para notificaciones leídas
    final contentOpacity = notification.isRead ? 0.6 : 1.0;

    final tileContent = InkWell(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context, isDark),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono con fondo circular
            Opacity(
              opacity: contentOpacity,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  size: 22,
                  color: config.color,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            
            // Contenido principal
            Expanded(
              child: Opacity(
                opacity: contentOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      notification.title,
                      style: (isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight)
                          .copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xs / 2),
                    
                    // Descripción
                    Text(
                      notification.description,
                      style: isDark
                          ? AppTypography.bodySmallDark
                          : AppTypography.bodySmallLight,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            
            // Tiempo relativo e indicador
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tiempo relativo
                Opacity(
                  opacity: contentOpacity,
                  child: Text(
                    notification.relativeTime,
                    style: AppTypography.label.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ),
                
                // Indicador de no leído
                if (!notification.isRead) ...[
                  SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // Si hay callback de dismiss, envolver en Dismissible
    if (onDismissed != null) {
      return Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: AppSpacing.xl),
          color: AppColors.danger,
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        child: tileContent,
      );
    }

    return tileContent;
  }

  void _showContextMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppColors.cardBackgroundDark
          : AppColors.cardBackgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            
            // Notification preview
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: notification.config.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.config.icon,
                      size: 22,
                      color: notification.config.color,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: (isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight)
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(
              height: AppSpacing.lg * 2,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            
            // Marcar como leída
            if (!notification.isRead)
              ListTile(
                leading: Icon(
                  Icons.mark_email_read_outlined,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.foreground,
                ),
                title: Text(
                  'Marcar como leída',
                  style: isDark
                      ? AppTypography.bodyDark
                      : AppTypography.bodyLight,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onMarkAsRead?.call();
                },
              ),
            
            // Eliminar
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: Text(
                'Eliminar',
                style: (isDark
                        ? AppTypography.bodyDark
                        : AppTypography.bodyLight)
                    .copyWith(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(context);
                onDismissed?.call();
              },
            ),
            
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
