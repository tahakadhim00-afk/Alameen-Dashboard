import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/subscriber_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Al Ameen Dashboard',
            locale: provider.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ar'), // Arabic
            ],
            theme: _buildThemeData(context),
            home: const SubscriberListScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildThemeData(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF0D7377),
      scaffoldBackgroundColor: const Color(0xFF141414),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF212121),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF212121),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF212121),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFF32E0C4), width: 2.0),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D7377),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF32E0C4),
        foregroundColor: Colors.black,
      ),
      textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme).copyWith(
        displayLarge: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
        displayMedium: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
        displaySmall: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
        headlineLarge: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
        headlineMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        headlineSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
        bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        bodySmall: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
        labelLarge: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
        labelMedium: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70),
        labelSmall: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0D7377),
        secondary: Color(0xFF32E0C4),
        surface: Color(0xFF212121),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
    );
  }
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
