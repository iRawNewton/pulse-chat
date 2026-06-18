import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pulse_chat/core/database/app_prefs.dart';
import 'package:tostore/tostore.dart';

@singleton
class PrefsStore {
  PrefsStore() : _db = _openDatabase();
  static const _prefsKey = 'app_prefs';

  final Future<ToStore> _db;
  AppPrefs _cachedPrefs = const AppPrefs();

  AppPrefs get cachedPrefs => _cachedPrefs;

  Future<void> init() async {
    await _db;
    _cachedPrefs = await load();
  }

  Future<AppPrefs> load() async {
    final db = await _db;
    final data = await db.getValue(_prefsKey);
    return _decode(data);
  }

  Future<void> save(AppPrefs prefs) async {
    _cachedPrefs = prefs;
    final db = await _db;
    await db.setValue(_prefsKey, prefs.toJson());
  }

  Stream<AppPrefs> watch() async* {
    final db = await _db;
    yield* db.watchValue<Map<dynamic, dynamic>>(_prefsKey).map((data) {
      final decoded = _decode(data);
      _cachedPrefs = decoded;
      return decoded;
    });
  }

  AppPrefs _decode(Object? data) {
    if (data is! Map) {
      return const AppPrefs();
    }

    try {
      return AppPrefs.fromJson(Map<String, dynamic>.from(data));
    } on Object {
      return const AppPrefs();
    }
  }

  static Future<ToStore> _openDatabase() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return ToStore.open(dbPath: appDirectory.path, dbName: 'pulse_chat');
  }
}
