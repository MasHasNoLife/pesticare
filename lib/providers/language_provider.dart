import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    _loadLanguage();
  }

  static const _languageKey = 'selectedLanguage';

  Locale _locale = const Locale('en');
  bool _isLoading = true;
  bool _hasSavedLanguage = false;
  Map<String, String> _localizedStrings =
      Map<String, String>.from(_fallbackEnglish);

  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  bool get hasSavedLanguage => _hasSavedLanguage;
  Map<String, String> get localizedStrings => _localizedStrings;

  String translate(String key) {
    return _localizedStrings[key] ?? _fallbackEnglish[key] ?? key;
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey);
    if (savedCode != null) {
      _locale = Locale(savedCode);
      _hasSavedLanguage = true;
    }
    await _loadLocalizedStrings(_locale.languageCode);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _hasSavedLanguage = true;
    await _loadLocalizedStrings(languageCode);
    notifyListeners();
  }

  Future<void> _loadLocalizedStrings(String code) async {
    try {
      final jsonString = await rootBundle.loadString('assets/lang/$code.json');
      final Map<String, dynamic> jsonMap =
          json.decode(jsonString) as Map<String, dynamic>;
      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (_) {
      _localizedStrings = Map<String, String>.from(_fallbackEnglish);
    }
  }
}

const Map<String, String> _fallbackEnglish = {
  'appName': 'Pesti-Care',
  'tagline': 'Smart crop disease assistant',
  'chooseLanguage': 'Choose Language',
  'english': 'English',
  'urdu': 'Urdu',
  'continue': 'Continue',
  'selectCrop': 'Select Crop',
  'cropSubtitle': 'Scan leaves to detect diseases',
  'cotton': 'Cotton',
  'rice': 'Rice',
  'wheat': 'Wheat',
  'captureImage': 'Capture Image',
  'uploadImage': 'Upload Image',
  'analyzeDisease': 'Analyze Disease',
  'selectedCrop': 'Selected Crop',
  'diseaseName': 'Disease',
  'confidence': 'Confidence',
  'recommendedPesticide': 'Recommended Pesticide',
  'dosage': 'Dosage',
  'scanAnother': 'Scan Another Image',
  'noImage': 'Please capture or upload a leaf photo first.',
  'predicting': 'Running smart analysis...',
  'languageSaved': 'Language preference saved',
  'loading': 'Loading',
  'error': 'Something went wrong',
  'changeImage': 'Change Image',
  'tapUpload': 'Tap to Upload or Capture Image',
  'camera': 'Capture with Camera',
  'gallery': 'Choose from Gallery',
  'analysisComplete': 'Diagnosis Complete!',
  'detectedDisease': 'Detected Disease',
  'recommendedCure': 'Recommended Cure',
  'saveHistory': 'Save to History',
  'diagnoseAnother': 'Diagnose Another',
};

