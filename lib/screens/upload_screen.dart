import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/language_provider.dart';
import '../providers/prediction_provider.dart';
import '../widgets/language_action_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  static const routeName = '/upload';

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _previewImage;
  String _cropKey = 'cotton';
  bool _initializedCrop = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedCrop) {
      final cropKey = ModalRoute.of(context)?.settings.arguments as String?;
      if (cropKey != null) {
        _cropKey = cropKey;
      }
      _initializedCrop = true;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final predictionProvider = context.read<PredictionProvider>();
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _previewImage = file;
      });
      predictionProvider.setImage(file);
    }
  }

  Future<void> _analyze() async {
    final localization = context.read<LanguageProvider>();
    final predictionProvider = context.read<PredictionProvider>();
    if (_previewImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.translate('noImage'))),
      );
      return;
    }
    try {
      final result = await predictionProvider.analyzeDisease();
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        ResultScreen.routeName,
        arguments: {
          ...result,
          'cropKey': _cropKey,
        },
      );
    } catch (e) {
      // The error is now handled by the predictionProvider's errorMessage getter
      // which will trigger a rebuild and display the error directly on screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LanguageProvider>();
    final predictionProvider = context.watch<PredictionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate(_cropKey)),
        actions: const [
          ThemeToggleButton(),
          LanguageActionButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show Lottie animation when analyzing
            if (predictionProvider.isAnalyzing)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/analyzing.json',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localization.translate('predicting'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _previewImage == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              localization.translate('uploadImage'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(
                        _previewImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            // Show error message on screen instead of SnackBar
            if (predictionProvider.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        predictionProvider.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: localization.translate('captureImage'),
                    icon: Icons.photo_camera,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: localization.translate('uploadImage'),
                    icon: Icons.photo_library_rounded,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: predictionProvider.isAnalyzing ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(localization.translate('analyzeDisease')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }
}

