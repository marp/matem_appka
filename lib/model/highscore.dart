import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HighScore {
  final String username;
  final int score;

  HighScore({required this.username,
    required this.score});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'score': score,
    };
  }

  factory HighScore.fromMap(Map<String, dynamic> map) {
    return HighScore(
        username: map['username'] as String,
        score: map['score'] as int);
  }

  save() async {

    final prefs = await SharedPreferences.getInstance();

    String? initialHighScores = prefs.getString('highscores');
    List currentHighScores = [];
    Map map = toMap();

    if (initialHighScores != null) {
      currentHighScores = jsonDecode(initialHighScores);
    }

    currentHighScores.add(map);  currentHighScores.sort((a, b) => (b["score"]).compareTo(a["score"]));
    // Keep 10 records max:
    currentHighScores = currentHighScores.take(10).toList();  await prefs.setString('highscores', jsonEncode(currentHighScores));
  }


}