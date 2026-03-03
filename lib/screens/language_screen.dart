import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../widgets/theme_toggle_button.dart';
import 'home_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const routeName = '/language';

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LanguageProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('chooseLanguage')),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('tagline'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            _LanguageOptionCard(
              title: localization.translate('english'),
              subTitle: 'English - Recommended for international farmers',
              onTap: () => _onLanguageSelected(context, 'en'),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _LanguageOptionCard(
              title: localization.translate('urdu'),
              subTitle: 'اردو - کسان بھائیوں کے لئے',
              onTap: () => _onLanguageSelected(context, 'ur'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLanguageSelected(BuildContext context, String code) async {
    final languageProvider = context.read<LanguageProvider>();
    await languageProvider.changeLanguage(code);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageProvider.translate('languageSaved')),
      ),
    );
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.title,
    required this.subTitle,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final String subTitle;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: isPrimary
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(
              Icons.language,
              color: isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subTitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

