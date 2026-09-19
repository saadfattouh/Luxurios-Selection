import 'package:flutter/material.dart';

class ExhibitionTokens {
  static const background = Color(0xFF101211);
  static const surface = Color(0xFF1A1E1C);
  static const ink = Color(0xFFF0EEE6);
  static const muted = Color(0xFFB3B8AF);
  static const accent = Color(0xFFC7B891);
  static const line = Color(0xFF3D443E);
  static const glass = Color(0xCC1A1E1C);
  static const radius = 4.0;
  static const space = 8.0;
  static const touch = 48.0;
  static const reveal = Duration(milliseconds: 1800);
  static const transition = Duration(milliseconds: 650);
  static const curve = Curves.easeOutCubic;
  static const depth = BoxShadow(
    color: Color(0x99000000),
    blurRadius: 48,
    offset: Offset(0, 28),
  );
  static double gutter(double width) => width >= 1000
      ? 64
      : width >= 600
      ? 40
      : 24;
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: accent,
      onPrimary: background,
      onSurface: ink,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'serif',
        fontSize: 68,
        height: 1.05,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'serif',
        fontSize: 40,
        height: 1.15,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'serif',
        fontSize: 28,
        height: 1.2,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.5, color: muted),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: muted),
      labelLarge: TextStyle(fontSize: 12, letterSpacing: 2, color: ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
