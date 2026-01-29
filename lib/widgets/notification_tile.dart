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

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = notification.config;
    
    // Opacidad reducida para notificaciones leídas
    final contentOpacity = notification.isRead ? 0.6 : 1.0;

    return InkWell(
      onTap: onTap,
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
  }
}
