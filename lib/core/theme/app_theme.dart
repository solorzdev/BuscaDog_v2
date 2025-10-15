import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B3B8F),
    ); // azul BBVA-like
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7F9),
        foregroundColor: scheme.onSurface,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF0D1B2A), // azul muy oscuro
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
