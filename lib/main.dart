import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/language_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/language_screen.dart';
import 'screens/result_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/history_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const PestiCareApp());
}

class PestiCareApp extends StatelessWidget {
  const PestiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, _) {
          if (languageProvider.isLoading || themeProvider.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            );
          }

          final isUrdu = languageProvider.locale.languageCode == 'ur';

          final lightTheme =
              _buildTheme(isUrdu: isUrdu, brightness: Brightness.light);
          final darkTheme =
              _buildTheme(isUrdu: isUrdu, brightness: Brightness.dark);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pesti-Care',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ur'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            // Custom page transitions
            onGenerateRoute: (settings) {
              final routes = {
                LanguageScreen.routeName: const LanguageScreen(),
                HomeScreen.routeName: const HomeScreen(),
                UploadScreen.routeName: const UploadScreen(),
                ResultScreen.routeName: const ResultScreen(),
                HistoryScreen.routeName: const HistoryScreen(),
                AboutScreen.routeName: const AboutScreen(),
              };

              final page = routes[settings.name];
              if (page != null) {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => page,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
                      CurveTween(curve: curve),
                    );
                    
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: FadeTransition(
                        opacity: animation.drive(fadeTween),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({
    required bool isUrdu,
    required Brightness brightness,
  }) {
    final seedColor = Colors.green.shade600;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF8F9FB)
          : const Color(0xFF0F1115),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      cardColor: colorScheme.surfaceContainerHighest,
    );

    final textTheme = isUrdu
        ? baseTheme.textTheme.apply(fontFamily: 'NotoNastaliq')
        : baseTheme.textTheme.copyWith(
            bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );

    return baseTheme.copyWith(
      textTheme: textTheme,
    );
  }
}
