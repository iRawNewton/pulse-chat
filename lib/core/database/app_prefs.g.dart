// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_prefs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppPrefs _$AppPrefsFromJson(Map<String, dynamic> json) => _AppPrefs(
  themeMode:
      $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
      defaultThemeMode,
  languageCode: json['languageCode'] as String? ?? defaultLanguageCode,
);

Map<String, dynamic> _$AppPrefsToJson(_AppPrefs instance) => <String, dynamic>{
  'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
  'languageCode': instance.languageCode,
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
