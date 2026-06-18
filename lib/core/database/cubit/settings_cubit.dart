import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:pulse_chat/core/database/app_prefs.dart';
import 'package:pulse_chat/core/database/prefs_store.dart';

@injectable
class SettingsCubit extends Cubit<AppPrefs> {
  SettingsCubit(this._prefsStore) : super(_prefsStore.cachedPrefs);

  final PrefsStore _prefsStore;

  Future<void> updateTheme(ThemeMode mode) async {
    await _save(state.copyWith(themeMode: mode));
  }

  Future<void> updateLanguage(String code) async {
    await _save(state.copyWith(languageCode: code));
  }

  Stream<AppPrefs> get prefsStream => _prefsStore.watch();

  Future<void> _save(AppPrefs prefs) async {
    await _prefsStore.save(prefs);
    if (isClosed) {
      return;
    }
    emit(prefs);
  }
}
