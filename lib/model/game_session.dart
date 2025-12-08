import 'dart:convert';
import 'package:uuid/uuid.dart';

class GameSession {
  GameSession({
    String? id,
    required this.playedAt,
    required this.gameType,
    required this.xpEarned,
    required this.score,
    this.durationSeconds,
    this.mistakes,
  }) : id = id ?? _newId();

  static final Uuid _uuid = Uuid();
  static String _newId() => _uuid.v4();

  final String id;
  final DateTime playedAt;
  final String gameType;
  final int xpEarned;
  final int score;
  final int? durationSeconds;
  final int? mistakes;

  DateTime get dayOnly => DateTime(playedAt.year, playedAt.month, playedAt.day);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'playedAt': playedAt.toIso8601String(),
      'gameType': gameType,
      'xpEarned': xpEarned,
      'score': score,
      'durationSeconds': durationSeconds,
      'mistakes': mistakes,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String?,
      playedAt: DateTime.parse(json['playedAt'] as String),
      gameType: json['gameType'] as String,
      xpEarned: (json['xpEarned'] ?? 0) as int,
      score: (json['score'] ?? 0) as int,
      durationSeconds: json['durationSeconds'] as int?,
      mistakes: json['mistakes'] as int?,
    );
  }

  static String encodeList(List<GameSession> sessions) =>
      json.encode(sessions.map((s) => s.toJson()).toList());

  static List<GameSession> decodeList(String value) {
    if (value.isEmpty) return <GameSession>[];
    final List<dynamic> raw = json.decode(value) as List<dynamic>;
    return raw
        .map((e) => GameSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
