import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static String _generateKey(String key, {String? identifier}) {
    return identifier != null && identifier.isNotEmpty ? '${key}_$identifier' : key;
  }

  static Future<void> saveData(String key, String value, {String? identifier}) async {
    final prefs = await _prefs;
    await prefs.setString(_generateKey(key, identifier: identifier), value);
  }

  static Future<String?> getData(String key, {String? identifier}) async {
    final prefs = await _prefs;
    return prefs.getString(_generateKey(key, identifier: identifier));
  }

  static Future<void> removeData(String key, {String? identifier}) async {
    final prefs = await _prefs;
    await prefs.remove(_generateKey(key, identifier: identifier));
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}