import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyLimitStorage {
  static const String _key = 'daily_plays';
  
  static Future<Map<String, String>> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return {};
    return Map<String, String>.from(jsonDecode(json));
  }
  
  static Future<void> _saveData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }
  
  static Future<bool> hasPlayedToday(String categoryId) async {
    final data = await _loadData();
    final lastPlay = data[categoryId];
    if (lastPlay == null) return false;
    
    final lastPlayDate = DateTime.parse(lastPlay);
    final now = DateTime.now();
    return lastPlayDate.year == now.year && 
           lastPlayDate.month == now.month && 
           lastPlayDate.day == now.day;
  }
  
  static Future<void> recordPlay(String categoryId) async {
    final data = await _loadData();
    data[categoryId] = DateTime.now().toIso8601String();
    await _saveData(data);
  }
  
  static Future<String?> getLastPlayTime(String categoryId) async {
    final data = await _loadData();
    return data[categoryId];
  }
}
