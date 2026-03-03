import 'dart:convert';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalStorageService extends GetxService {
  static const _databaseName = 'motomileage.db';
  static const _databaseVersion = 1;
  static const _kvTable = 'kv_store';

  late Database _db;
  final Map<String, String> _cache = <String, String>{};

  Future<LocalStorageService> init() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, _databaseName);

    _db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_kvTable (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );

    final rows = await _db.query(_kvTable);
    for (final row in rows) {
      final key = row['key'] as String?;
      final value = row['value'] as String?;
      if (key != null && value != null) {
        _cache[key] = value;
      }
    }

    return this;
  }

  Set<String> getKeys() => _cache.keys.toSet();

  String? getString(String key) => _cache[key];

  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _db.insert(_kvTable, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  bool? getBool(String key) {
    final raw = _cache[key];
    if (raw == null) {
      return null;
    }
    if (raw == '1') {
      return true;
    }
    if (raw == '0') {
      return false;
    }
    return null;
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value ? '1' : '0');
  }

  Future<void> remove(String key) async {
    _cache.remove(key);
    await _db.delete(_kvTable, where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clear() async {
    _cache.clear();
    await _db.delete(_kvTable);
  }

  Future<void> setJsonMap(String key, Map<String, dynamic> value) {
    return setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJsonMap(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) {
    return setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }
}
