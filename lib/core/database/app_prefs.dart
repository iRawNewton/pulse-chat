import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_prefs.freezed.dart';
part 'app_prefs.g.dart';

const String defaultLanguageCode = 'en';
const ThemeMode defaultThemeMode = ThemeMode.system;

@freezed
abstract class AppPrefs with _$AppPrefs {
  const factory AppPrefs({
    @Default(defaultThemeMode) ThemeMode themeMode,
    @Default(defaultLanguageCode) String languageCode,
  }) = _AppPrefs;

  factory AppPrefs.fromJson(Map<String, dynamic> json) =>
      _$AppPrefsFromJson(json);
}
