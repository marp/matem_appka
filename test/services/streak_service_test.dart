import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matem_appka/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StreakService.updateForToday', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await StreakService().reset();
    });

    test('first ever update sets currentStreak=1 and bestStreak=1', () async {
      final service = StreakService();
      await service.initialize();

      await service.updateForToday();

      expect(service.currentStreak, 1);
      expect(service.bestStreak, 1);
      expect(service.lastPlayedDate, isNotNull);
    });

    test('calling update twice the same day does not increment streak', () async {
      final today = DateTime.now();
      final todayStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues(<String, Object>{
        'streak_current': 1,
        'streak_best': 1,
        'streak_last_played': todayStr,
      });

      final service = StreakService();
      await service.initialize();

      await service.updateForToday();

      expect(service.currentStreak, 1);
      expect(service.bestStreak, 1);
      expect(service.lastPlayedDate, todayStr);
    });

    test('when last played was yesterday, update increments currentStreak',
        () async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));

      final yesterdayStr =
          '${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues(<String, Object>{
        'streak_current': 2,
        'streak_best': 2,
        'streak_last_played': yesterdayStr,
      });

      final service = StreakService();
      await service.initialize();
      await service.updateForToday();

      expect(service.currentStreak, 3);
      expect(service.bestStreak, 3);
    });

    test('when there is a break (more than 1 day), streak resets to 1',
        () async {
      final now = DateTime.now();
      final threeDaysAgo = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 3));

      final threeDaysAgoStr =
          '${threeDaysAgo.year.toString().padLeft(4, '0')}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues(<String, Object>{
        'streak_current': 5,
        'streak_best': 5,
        'streak_last_played': threeDaysAgoStr,
      });

      final service = StreakService();
      await service.initialize();
      await service.updateForToday();

      expect(service.currentStreak, 1);
      // best streak should not go down
      expect(service.bestStreak, 5);
    });
  });
}

