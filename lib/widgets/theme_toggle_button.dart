import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    this.showBackButton = false,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final canShowBack = showBackButton && Navigator.of(context).canPop();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canShowBack)
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).maybePop();
              }
            },
          ),
        IconButton(
          icon: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: themeProvider.toggleTheme,
        ),
      ],
    );
  }
}

