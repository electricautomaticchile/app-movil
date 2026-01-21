// path: lib/widgets/text_link.dart

import 'package:flutter/material.dart';
import '../theme/typography.dart';

class TextLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const TextLink({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: text,
      link: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            text,
            style: isDark ? AppTypography.linkDark : AppTypography.linkLight,
          ),
        ),
      ),
    );
  }
}
