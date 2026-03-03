import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../screens/language_screen.dart';

class LanguageActionButton extends StatelessWidget {
  const LanguageActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LanguageProvider>();
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushNamed(LanguageScreen.routeName);
      },
      tooltip: localization.translate('chooseLanguage'),
      icon: const Icon(Icons.language_rounded),
    );
  }
}

