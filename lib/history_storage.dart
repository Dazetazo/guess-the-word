import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameHistory {
  final String word;
  final String category;
  final String language;
  final DateTime date;
  final int attempts;
  
  GameHistory({
    required this.word,
    required this.category,
    required this.language,
    required this.date,
    required this.attempts,
  });
  
  Map<String, dynamic> toJson() => {
    'word': word,
    'category': category,
    'language': language,
    'date': date.toIso8601String(),
    'attempts': attempts,
  };
  
  factory GameHistory.fromJson(Map<String, dynamic> json) => GameHistory(
    word: json['word'],
    category: json['category'],
    language: json['language'],
    date: DateTime.parse(json['date']),
    attempts: json['attempts'],
  );
}

class HistoryStorage {
  static const String _key = 'game_history';
  
  static Future<List<GameHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => GameHistory.fromJson(json)).toList();
  }
  
  static Future<void> addEntry(GameHistory entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.add(entry);
    
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }
  
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
