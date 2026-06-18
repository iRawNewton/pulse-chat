import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

class AppTheme {
  /// LIGHT THEME
  static ThemeData lightTheme(BuildContext context) {
    final colors = AppColors(context);
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      fontFamily: 'Outfit',
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.error,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.w700.copyWith(fontSize: 32, color: colors.textPrimary, letterSpacing: -0.5),
        displayMedium: AppTextStyles.w700.copyWith(fontSize: 28, color: colors.textPrimary, letterSpacing: -0.5),
        displaySmall: AppTextStyles.w700.copyWith(fontSize: 24, color: colors.textPrimary),
        headlineLarge: AppTextStyles.w600.copyWith(fontSize: 22, color: colors.textPrimary),
        headlineMedium: AppTextStyles.w600.copyWith(fontSize: 20, color: colors.textPrimary),
        headlineSmall: AppTextStyles.w600.copyWith(fontSize: 18, color: colors.textPrimary),
        titleLarge: AppTextStyles.w600.copyWith(fontSize: 16, color: colors.textPrimary),
        titleMedium: AppTextStyles.w500.copyWith(fontSize: 14, color: colors.textPrimary),
        titleSmall: AppTextStyles.w500.copyWith(fontSize: 12, color: colors.textPrimary),
        bodyLarge: AppTextStyles.w400.copyWith(fontSize: 16, color: colors.textPrimary, height: 1.5),
        bodyMedium: AppTextStyles.w400.copyWith(fontSize: 14, color: colors.textPrimary, height: 1.5),
        bodySmall: AppTextStyles.w400.copyWith(fontSize: 12, color: colors.textSecondary, height: 1.5),
        labelLarge: AppTextStyles.w600.copyWith(fontSize: 14, color: colors.textPrimary, letterSpacing: 0.5),
        labelMedium: AppTextStyles.w500.copyWith(fontSize: 12, color: colors.textSecondary, letterSpacing: 0.5),
        labelSmall: AppTextStyles.w500.copyWith(fontSize: 10, color: colors.textSecondary, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: AppTextStyles.w600.copyWith(fontSize: 20, color: colors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.w600.copyWith(fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.w600.copyWith(fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.w600.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        labelStyle: AppTextStyles.w400.copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.w400.copyWith(color: colors.textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        deleteIconColor: colors.textSecondary,
        labelStyle: AppTextStyles.w400.copyWith(color: colors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.border),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.w600.copyWith(color: colors.textPrimary),
      ),
    );
  }

  /// DARK THEME
  static ThemeData darkTheme(BuildContext context) {
    final colors = AppColors(context);
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      fontFamily: 'Outfit',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        onError: Colors.white,
        outline: colors.border,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.w700.copyWith(fontSize: 32, color: colors.textPrimary, letterSpacing: -0.5),
        displayMedium: AppTextStyles.w700.copyWith(fontSize: 28, color: colors.textPrimary, letterSpacing: -0.5),
        displaySmall: AppTextStyles.w700.copyWith(fontSize: 24, color: colors.textPrimary),
        headlineLarge: AppTextStyles.w600.copyWith(fontSize: 22, color: colors.textPrimary),
        headlineMedium: AppTextStyles.w600.copyWith(fontSize: 20, color: colors.textPrimary),
        headlineSmall: AppTextStyles.w600.copyWith(fontSize: 18, color: colors.textPrimary),
        titleLarge: AppTextStyles.w600.copyWith(fontSize: 16, color: colors.textPrimary),
        titleMedium: AppTextStyles.w500.copyWith(fontSize: 14, color: colors.textPrimary),
        titleSmall: AppTextStyles.w500.copyWith(fontSize: 12, color: colors.textPrimary),
        bodyLarge: AppTextStyles.w400.copyWith(fontSize: 16, color: colors.textPrimary, height: 1.5),
        bodyMedium: AppTextStyles.w400.copyWith(fontSize: 14, color: colors.textPrimary, height: 1.5),
        bodySmall: AppTextStyles.w400.copyWith(fontSize: 12, color: colors.textSecondary, height: 1.5),
        labelLarge: AppTextStyles.w600.copyWith(fontSize: 14, color: colors.textPrimary, letterSpacing: 0.5),
        labelMedium: AppTextStyles.w500.copyWith(fontSize: 12, color: colors.textSecondary, letterSpacing: 0.5),
        labelSmall: AppTextStyles.w500.copyWith(fontSize: 10, color: colors.textSecondary, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: AppTextStyles.w600.copyWith(fontSize: 20, color: colors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.w600.copyWith(fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.w600.copyWith(fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.w600.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        labelStyle: AppTextStyles.w400.copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.w400.copyWith(color: colors.textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        deleteIconColor: colors.textSecondary,
        labelStyle: AppTextStyles.w400.copyWith(color: colors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.border),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.w600.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
