import 'package:flutter/material.dart';

class AppTheme {
  // RAPID REACH brand colors
  static const Color primaryBlue = Color(0xFF087FCE);
  static const Color cyanBlue = Color(0xFF19C6E6);
  static const Color darkNavy = Color(0xFF102A56);
  static const Color lightBlue = Color(0xFFEAF6FF);
  static const Color background = Color(0xFFF8FCFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryBlue,
        secondary: cyanBlue,
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkNavy,
        elevation: 0,
        centerTitle: false,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: darkNavy,
        ),
        displayMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: darkNavy,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: darkNavy,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: darkNavy,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          height: 1.5,
          color: Color(0xFF40516D),
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.4,
          color: Color(0xFF52627A),
        ),
      ),
    );
  }
}