import 'package:shared_preferences/shared_preferences.dart';

class SharedHelper {
  static late final SharedPreferences prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> save(String key, dynamic value) async {
    if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    }
    return false;
  }

  static dynamic get(String key) {
    return prefs.get(key);
  }

  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  static Future<bool> clear() async {
    return await prefs.clear();
  }
}
