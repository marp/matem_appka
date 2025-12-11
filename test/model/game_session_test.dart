import 'package:flutter_test/flutter_test.dart';
import 'package:matem_appka/model/game_session.dart';

void main() {
  test('New GameSession gets a non-empty UUID id', () {
    final session = GameSession(
      playedAt: DateTime.now(),
      gameType: 'test',
      xpEarned: 10,
      score: 5,
    );

    expect(session.id, isNotEmpty);
    // Basic UUID format check: 36 chars with hyphens
    expect(session.id.length, 36);
  });

  test('encodeList/decodeList preserves id', () {
    final s1 = GameSession(
      id: '11111111-1111-1111-1111-111111111111',
      playedAt: DateTime.parse('2025-01-01T12:00:00.000Z'),
      gameType: 'g1',
      xpEarned: 10,
      score: 1,
    );
    final s2 = GameSession(
      id: '22222222-2222-2222-2222-222222222222',
      playedAt: DateTime.parse('2025-01-02T12:00:00.000Z'),
      gameType: 'g2',
      xpEarned: 20,
      score: 2,
    );

    final encoded = GameSession.encodeList([s1, s2]);
    final decoded = GameSession.decodeList(encoded);

    expect(decoded.length, 2);
    expect(decoded[0].id, s1.id);
    expect(decoded[1].id, s2.id);
  });

  test('fromJson without id generates new id', () {
    final json = <String, dynamic>{
      'playedAt': '2025-01-01T12:00:00.000Z',
      'gameType': 'legacy',
      'xpEarned': 5,
      'score': 3,
    };

    final session = GameSession.fromJson(json);

    expect(session.id, isNotEmpty);
    expect(session.gameType, 'legacy');
    expect(session.score, 3);
  });
}

