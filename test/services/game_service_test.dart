import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:matem_appka/const/game.dart';
import 'package:matem_appka/services/game_service.dart';

void main() {
  group('GameService.calculateResult', () {
    test('add/subtract/multiply/divide basics', () {
      expect(GameService.calculateResult(2, 3, MathOperation.add), 5);
      expect(GameService.calculateResult(7, 4, MathOperation.subtract), 3);
      expect(GameService.calculateResult(6, 5, MathOperation.multiply), 30);
      expect(GameService.calculateResult(7, 2, MathOperation.divide), 3);
    });

    test('divide by zero returns 0', () {
      expect(GameService.calculateResult(7, 0, MathOperation.divide), 0);
    });
  });

  group('GameService.submitAnswer', () {
    test('correct increments score for non-practice mode', () {
      final service = GameService(random: Random(1));
      service.start(mode: GameMode.play);

      final correct = service.state.question.correctAnswer();
      final outcome = service.submitAnswer(correct);

      expect(outcome, AnswerOutcome.correct);
      expect(service.state.score, 1);
    });

    test('correct does not increment score for practice mode', () {
      final service = GameService(random: Random(1));
      service.start(mode: GameMode.practice);

      final correct = service.state.question.correctAnswer();
      final outcome = service.submitAnswer(correct);

      expect(outcome, AnswerOutcome.correct);
      expect(service.state.score, 0);
    });

    test('incorrect decrements mistakes only in play mode and triggers gameOver at 0', () {
      final service = GameService(random: Random(1));
      service.start(mode: GameMode.play);

      expect(service.state.remainingMistakes, 3);

      expect(service.submitAnswer(null), AnswerOutcome.incorrect);
      expect(service.state.remainingMistakes, 2);

      expect(service.submitAnswer(null), AnswerOutcome.incorrect);
      expect(service.state.remainingMistakes, 1);

      expect(service.submitAnswer(null), AnswerOutcome.gameOver);
      expect(service.state.remainingMistakes, 0);
    });

    test('incorrect does not decrement mistakes in timetrial mode', () {
      final service = GameService(random: Random(1));
      service.start(mode: GameMode.timetrial);

      final before = service.state.remainingMistakes;
      final outcome = service.submitAnswer(null);

      expect(outcome, AnswerOutcome.incorrect);
      expect(service.state.remainingMistakes, before);
    });
  });
}

