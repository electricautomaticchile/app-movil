// path: lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class AppDrawer extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onSelect;

  const AppDrawer({
    super.key,
    required this.selectedKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Container(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.card,
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Main menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    itemKey: 'home',
                    selected: selectedKey == 'home',
                    onTap: () {
                      Navigator.pop(context);
                      onSelect('home');
                    },
                  ),
                  SizedBox(height: AppSpacing.xs),
                  _DrawerItem(
                    icon: Icons.devices_outlined,
                    label: 'Medidores',
                    itemKey: 'meters',
                    selected: selectedKey == 'meters',
                    onTap: () {
                      Navigator.pop(context);
                      onSelect('meters');
                    },
                  ),
                  SizedBox(height: AppSpacing.xs),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Alertas',
                    itemKey: 'alerts',
                    selected: selectedKey == 'alerts',
                    trailingBadge: '3',
                    onTap: () {
                      Navigator.pop(context);
                      onSelect('alerts');
                    },
                  ),
                  SizedBox(height: AppSpacing.xs),
                  _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reportes',
                    itemKey: 'reports',
                    selected: selectedKey == 'reports',
                    onTap: () {
                      Navigator.pop(context);
                      onSelect('reports');
                    },
                  ),
                ],
              ),
            ),

            // Bottom section
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.pop(context),
            color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
          ),

          // Title
          Text(
            'Electricautomaticchile',
            style:
                (isDark
                        ? AppTypography.bodyLargeDark
                        : AppTypography.bodyLargeLight)
                    .copyWith(fontWeight: FontWeight.bold),
          ),

          // Notification bell with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                  onSelect('notifications');
                },
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.foreground,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.badgeRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: isDark ? AppColors.borderDark : AppColors.border,
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                itemKey: 'settings',
                selected: selectedKey == 'settings',
                onTap: () {
                  Navigator.pop(context);
                  onSelect('settings');
                },
              ),
              SizedBox(height: AppSpacing.xs),
              _DrawerItem(
                icon: Icons.logout,
                label: 'Salir',
                itemKey: 'logout',
                selected: false,
                isDanger: true,
                onTap: () {
                  Navigator.pop(context);
                  onSelect('logout');
                },
              ),
              SizedBox(height: AppSpacing.md),
              // Footer version
              Text(
                'Electric v1.0.2',
                style:
                    (isDark
                            ? AppTypography.bodySmallDark
                            : AppTypography.bodySmallLight)
                        .copyWith(
                          color:
                              (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.mutedForeground)
                                  .withOpacity(0.6),
                        ),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String itemKey;
  final bool selected;
  final String? trailingBadge;
  final bool isDanger;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.itemKey,
    required this.selected,
    this.trailingBadge,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color iconColor = isDanger
        ? AppColors.danger
        : (selected
              ? AppColors.primary
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground));

    final Color textColor = isDanger
        ? AppColors.danger
        : (selected
              ? AppColors.primary
              : (isDark ? AppColors.textPrimaryDark : AppColors.foreground));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style:
                    (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                        .copyWith(
                          color: textColor,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
              ),
            ),
            if (trailingBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  trailingBadge!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
