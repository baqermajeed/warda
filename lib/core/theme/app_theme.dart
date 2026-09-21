import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// اسم عائلة خط التطبيق (Lama Sans).
const String kFontFamily = 'LamaSans';

/// ثيم التطبيق باستخدام ألوان warda وخط Lama Sans.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: kFontFamily,
      textTheme: _buildTextTheme(),
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.primaryLight,
        secondary: AppColors.primaryMedium,
        onSecondary: AppColors.primaryLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: kFontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.primaryLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: kFontFamily,
      textTheme: _buildTextTheme(),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.primaryDark,
        secondary: AppColors.primaryBeige,
        onSecondary: AppColors.primaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.borderDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: AppColors.textSecondaryDark,
          fontFamily: kFontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600),
    );
  }
}
