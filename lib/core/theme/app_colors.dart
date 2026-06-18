import 'package:flutter/material.dart';

class AppColors {
  AppColors(this.context);
  final BuildContext context;

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  /* ------------------------------- Semantic Getters ------------------------------ */

  // Backgrounds
  Color get background => isDarkMode ? backgroundDark : backgroundLight;
  Color get surface    => isDarkMode ? surfaceDark    : surfaceLight;
  Color get card       => isDarkMode ? cardDark       : cardLight;

  // Brand
  Color get primary          => isDarkMode ? darkPrimary          : lightPrimary;
  Color get secondary        => isDarkMode ? darkSecondary        : lightSecondary;
  Color get primaryMuted     => isDarkMode ? darkPrimaryMuted     : lightPrimaryMuted;
  Color get secondaryMuted   => isDarkMode ? darkSecondaryMuted   : lightSecondaryMuted;

  // Semantic
  Color get success        => isDarkMode ? darkSuccess        : lightSuccess;
  Color get error          => isDarkMode ? darkError          : lightError;
  Color get warning        => isDarkMode ? darkWarning        : lightWarning;
  Color get info           => isDarkMode ? darkInfo           : lightInfo;
  Color get successMuted   => isDarkMode ? darkSuccessMuted   : lightSuccessMuted;
  Color get errorMuted     => isDarkMode ? darkErrorMuted     : lightErrorMuted;
  Color get warningMuted   => isDarkMode ? darkWarningMuted   : lightWarningMuted;
  Color get infoMuted      => isDarkMode ? darkInfoMuted      : lightInfoMuted;

  // Text & border
  Color get textPrimary     => isDarkMode ? textPrimaryDark     : textPrimaryLight;
  Color get textSecondary   => isDarkMode ? textSecondaryDark   : textSecondaryLight;
  Color get textTertiary    => isDarkMode ? textTertiaryDark    : textTertiaryLight;
  Color get border          => isDarkMode ? borderDark          : borderLight;

  // Special
  Color get toggleIcon => isDarkMode ? const Color(0xFFFFB199) : primary;

  /* ----------------------------- Color Definitions ----------------------------- */

  // --- Backgrounds ---
  // Warm cream-grey for light (not stark white); dark uses a near-black
  // with a faint warm undertone so it pairs with the coral accent
  static const Color backgroundLight = Color(0xFFF7F3F0);
  static const Color backgroundDark  = Color(0xFF1A1718);

  // Surface sits one step lighter than background
  static const Color surfaceLight = Color(0xFFFFFCFA);
  static const Color surfaceDark  = Color(0xFF221E20);

  // Cards sit on top of surface
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark  = Color(0xFF2B262A);

  // --- Brand: Primary (vibrant coral/tangerine — warm, energetic, not blue) ---
  static const Color lightPrimary      = Color(0xFFFF6B4A); // Punchy coral
  static const Color darkPrimary       = Color(0xFFFF8566); // Lifted for dark bg contrast
  static const Color lightPrimaryMuted = Color(0xFFFFE8E0); // Tinted bg for bubbles/chips
  static const Color darkPrimaryMuted  = Color(0xFF4A2418); // Deep tint for dark mode

  // --- Brand: Secondary (deep teal-green — contrast without competing) ---
  static const Color lightSecondary      = Color(0xFF0E8C7F); // Rich teal
  static const Color darkSecondary       = Color(0xFF3FBFAE); // Pastel-lifted for dark
  static const Color lightSecondaryMuted = Color(0xFFDFF5F1);
  static const Color darkSecondaryMuted  = Color(0xFF103330);

  // --- Success (fresh lime-green, distinct from secondary teal) ---
  static const Color lightSuccess      = Color(0xFF4CAF50);
  static const Color darkSuccess       = Color(0xFF6FCC73);
  static const Color lightSuccessMuted = Color(0xFFE6F6E7);
  static const Color darkSuccessMuted  = Color(0xFF193A1B);

  // --- Error (deep rose-red, kept apart from coral primary) ---
  static const Color lightError      = Color(0xFFE5283F);
  static const Color darkError       = Color(0xFFFF5468);
  static const Color lightErrorMuted = Color(0xFFFCE4E7);
  static const Color darkErrorMuted  = Color(0xFF3A0F16);

  // --- Warning (golden amber) ---
  static const Color lightWarning      = Color(0xFFF2A93B);
  static const Color darkWarning       = Color(0xFFFFC069);
  static const Color lightWarningMuted = Color(0xFFFCF0DC);
  static const Color darkWarningMuted  = Color(0xFF3A2B0D);

  // --- Info (violet-orchid, set apart from primary/secondary) ---
  static const Color lightInfo      = Color(0xFF8B5CF6);
  static const Color darkInfo       = Color(0xFFA98AFA);
  static const Color lightInfoMuted = Color(0xFFEFE6FE);
  static const Color darkInfoMuted  = Color(0xFF2A1D40);

  // --- Text ---
  static const Color textPrimaryLight   = Color(0xFF231C1A);
  static const Color textPrimaryDark    = Color(0xFFF8F1EE);
  static const Color textSecondaryLight = Color(0xFF6B5D58);
  static const Color textSecondaryDark  = Color(0xFFC7BAB5);
  static const Color textTertiaryLight  = Color(0xFF9C8D87);
  static const Color textTertiaryDark   = Color(0xFF74686B);

  // --- Border ---
  static const Color borderLight = Color(0xFFE3D7D1);
  static const Color borderDark  = Color(0xFF3D3739);
}
