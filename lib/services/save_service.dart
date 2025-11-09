import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mythical_cats/models/game_state.dart';

class SaveService {
  static const String _saveKey = 'game_save';

  /// Save game state
  static Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_saveKey, json);
  }

  /// Load game state
  static Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (e) {
      // Invalid save data, return null
      return null;
    }
  }

  /// Delete save
  static Future<void> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  /// Check if save exists
  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }
}
