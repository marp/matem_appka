import 'package:shared_preferences/shared_preferences.dart';

import '../model/game_session.dart';
import 'streak_service.dart';

class ActivityService {
  ActivityService._internal();
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;

  static const String _kSessionsKey = 'activity_sessions_v1';

  final List<GameSession> _sessions = <GameSession>[];

  List<GameSession> get sessions => List.unmodifiable(_sessions);

  // DEBUG ONLY: zwraca listę mutowalną, używaną przez dev page
  List<GameSession> get debugMutableSessions => _sessions;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionsKey);
    if (raw != null && raw.isNotEmpty) {
      _sessions
        ..clear()
        ..addAll(GameSession.decodeList(raw));
    }
  }

  Future<void> addSession(GameSession session) async {
    _sessions.add(session);
    await _save();
    await StreakService().updateForToday();
  }

  Future<void> resetSessions() async {
    _sessions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionsKey);
  }

  Map<DateTime, List<GameSession>> sessionsByDayInRange(
      DateTime from, DateTime to) {
    final start = _dayOnly(from);
    final end = _dayOnly(to);
    final Map<DateTime, List<GameSession>> byDay = {};

    for (final s in _sessions) {
      final d = _dayOnly(s.playedAt);
      if (d.isBefore(start) || d.isAfter(end)) continue;
      byDay.putIfAbsent(d, () => <GameSession>[]).add(s);
    }

    return byDay;
  }

  List<GameSession> sessionsForDay(DateTime day) {
    final dayOnly = _dayOnly(day);
    return _sessions
        .where((s) => _isSameDay(s.playedAt, dayOnly))
        .toList(growable: false);
  }

  int xpForDay(DateTime day) {
    return sessionsForDay(day).fold(0, (sum, s) => sum + s.xpEarned);
  }

  List<int> xpForLast7Days() {
    final now = DateTime.now();
    final today = _dayOnly(now);
    final List<int> xp = List<int>.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final d = today.subtract(Duration(days: 6 - i));
      xp[i] = xpForDay(d);
    }

    return xp;
  }

  int get currentStreak => StreakService().currentStreak;

  int get bestStreak => StreakService().bestStreak;

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionsKey, GameSession.encodeList(_sessions));
  }

  // DEBUG ONLY: wymusza zapis aktualnej listy sesji (np. po ręcznych edycjach)
  Future<void> debugSaveSessions() => _save();

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
