// path: lib/widgets/screen_container.dart

import 'package:flutter/material.dart';
import '../theme/spacing.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  final bool centerContent;

  const ScreenContainer({
    super.key,
    required this.child,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;

        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(isWeb ? AppSpacing.xl : AppSpacing.md),
                constraints: BoxConstraints(
                  maxWidth: isWeb ? AppSpacing.cardMaxWidth : double.infinity,
                ),
                child: centerContent ? Center(child: child) : child,
              ),
            ),
          ),
        );
      },
    );
  }
}
