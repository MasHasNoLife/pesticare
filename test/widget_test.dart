// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pesticare/main.dart';
import 'package:pesticare/providers/language_provider.dart';
import 'package:pesticare/screens/home_screen.dart';

void main() {
  testWidgets('Pesti-Care app renders', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PestiCareApp());
    await tester.pumpAndSettle();

    expect(find.byType(PestiCareApp), findsOneWidget);
  });

  testWidgets('Urdu locale loads translations', (tester) async {
    SharedPreferences.setMockInitialValues({'selectedLanguage': 'ur'});

    await tester.pumpWidget(const PestiCareApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    final appContext = tester.element(find.byType(MaterialApp));
    final languageProvider =
        Provider.of<LanguageProvider>(appContext, listen: false);
    expect(languageProvider.locale.languageCode, 'ur');

    expect(find.byType(HomeScreen), findsOneWidget);

    final homeContext = tester.element(find.byType(HomeScreen));
    final localization =
        Provider.of<LanguageProvider>(homeContext, listen: false);
    expect(localization.locale.languageCode, 'ur');
    expect(localization.translate('selectCrop'), 'فصل منتخب کریں');

    expect(find.text('فصل منتخب کریں'), findsWidgets);
  });
}
