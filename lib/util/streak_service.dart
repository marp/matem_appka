import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  StreakService._internal();
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;

  static const String _kCurrentStreakKey = 'streak_current';
  static const String _kBestStreakKey = 'streak_best';
  static const String _kLastPlayedDateKey = 'streak_last_played';

  int _currentStreak = 0;
  int _bestStreak = 0;
  String? _lastPlayedDate;

  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  String? get lastPlayedDate => _lastPlayedDate;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt(_kCurrentStreakKey) ?? 0;
    _bestStreak = prefs.getInt(_kBestStreakKey) ?? 0;
    _lastPlayedDate = prefs.getString(_kLastPlayedDateKey);
  }

  Future<void> updateForToday() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    if (_lastPlayedDate == null) {
      _currentStreak = 1;
      _bestStreak = 1;
      _lastPlayedDate = todayStr;
      await _save(prefs);
      return;
    }

    if (_lastPlayedDate == todayStr) {
      // Already counted today
      return;
    }

    final last = _parseDate(_lastPlayedDate!);
    final yesterday = today.subtract(const Duration(days: 1));

    if (last.year == yesterday.year && last.month == yesterday.month && last.day == yesterday.day) {
      // consecutive day
      _currentStreak += 1;
    } else {
      // break in streak
      _currentStreak = 1;
    }

    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }

    _lastPlayedDate = todayStr;
    await _save(prefs);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = 0;
    _bestStreak = 0;
    _lastPlayedDate = null;
    await prefs.remove(_kCurrentStreakKey);
    await prefs.remove(_kBestStreakKey);
    await prefs.remove(_kLastPlayedDateKey);
  }

  Future<void> _save(SharedPreferences prefs) async {
    await prefs.setInt(_kCurrentStreakKey, _currentStreak);
    await prefs.setInt(_kBestStreakKey, _bestStreak);
    await prefs.setString(_kLastPlayedDateKey, _lastPlayedDate!);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime _parseDate(String value) {
    final parts = value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }
}

