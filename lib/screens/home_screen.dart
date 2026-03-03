import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/prediction_provider.dart';
import '../widgets/crop_card.dart';
import '../widgets/language_action_button.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/weather_widget.dart';
import 'upload_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LanguageProvider>();
    final crops = [
      _CropItem(
        keyName: 'cotton',
        assetPath: 'assets/images/cotton.png',
        subtitle: localization.translate('cropSubtitle'),
      ),
      _CropItem(
        keyName: 'rice',
        assetPath: 'assets/images/rice.png',
        subtitle: localization.translate('cropSubtitle'),
      ),
      _CropItem(
        keyName: 'wheat',
        assetPath: 'assets/images/wheat.png',
        subtitle: localization.translate('cropSubtitle'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('selectCrop')),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, HistoryScreen.routeName),
            tooltip: localization.translate('scanHistory'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, AboutScreen.routeName),
            tooltip: localization.translate('about') ?? 'About',
          ),
          const ThemeToggleButton(),
          const LanguageActionButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Weather widget at top
            const WeatherWidget(),
            // Crops grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return CropCard(
                    title: localization.translate(crop.keyName),
                    subtitle: crop.subtitle,
                    assetPath: crop.assetPath,
                    onTap: () => _onCropSelected(context, crop.keyName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCropSelected(BuildContext context, String cropKey) {
    final predictionProvider = context.read<PredictionProvider>();
    predictionProvider.selectCrop(cropKey);
    predictionProvider.reset();
    Navigator.pushNamed(
      context,
      UploadScreen.routeName,
      arguments: cropKey,
    );
  }
}

class _CropItem {
  _CropItem({
    required this.keyName,
    required this.assetPath,
    required this.subtitle,
  });

  final String keyName;
  final String assetPath;
  final String subtitle;
}
