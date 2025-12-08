import 'package:shared_preferences/shared_preferences.dart';

class XpService {
  XpService._internal();
  static final XpService _instance = XpService._internal();
  factory XpService() => _instance;

  static const String _kCurrentXpKey = 'xp_current';
  static const String _kTotalXpKey = 'xp_total';

  int _currentXp = 0;
  int _totalXp = 0;

  int get currentXp => _currentXp;
  int get totalXp => _totalXp;

  int get level => 1 + (_totalXp ~/ 100); // simple level formula for future use

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentXp = prefs.getInt(_kCurrentXpKey) ?? 0;
    _totalXp = prefs.getInt(_kTotalXpKey) ?? 0;
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    _currentXp += amount;
    _totalXp += amount;
    await _save(prefs);
  }

  Future<void> resetXp() async {
    final prefs = await SharedPreferences.getInstance();
    _currentXp = 0;
    _totalXp = 0;
    await prefs.remove(_kCurrentXpKey);
    await prefs.remove(_kTotalXpKey);
  }

  Future<void> _save(SharedPreferences prefs) async {
    await prefs.setInt(_kCurrentXpKey, _currentXp);
    await prefs.setInt(_kTotalXpKey, _totalXp);
  }
}

