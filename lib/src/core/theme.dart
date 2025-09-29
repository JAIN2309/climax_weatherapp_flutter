
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0077B6);
  static const Color accent = Color(0xFF00B4D8);
  static const Color bgLight = Color(0xFFE6F7FF);
  static const Color bgDark = Color(0xFF071126);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: Typography.blackMountainView,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
    scaffoldBackgroundColor: bgDark,
    appBarTheme: const AppBarTheme(elevation: 0),
    cardTheme: CardTheme(
      color: const Color(0xFF0B253C),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: Typography.whiteMountainView,
  );
}
