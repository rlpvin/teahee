import 'package:flutter/material.dart';

class AppColors {
  static const background = Colors.black;
  static const text = Colors.white;

  static const accentGreen = Color(0xFF00FF66); // bright green
  static const deepGreen = Color(0xFF006633); // save/yes
  static const dangerRed = Color(0xFF8B0000); // warning
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.accentGreen,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.text),
      bodyMedium: TextStyle(color: AppColors.text),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    iconTheme: const IconThemeData(color: AppColors.accentGreen),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: Colors.white,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
      ),
    ),
  );
}

class AppButtons {
  static ButtonStyle saveButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.deepGreen,
    foregroundColor: Colors.white,
  );

  static ButtonStyle cancelButton = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white),
  );

  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.dangerRed,
    foregroundColor: Colors.white,
  );
}
