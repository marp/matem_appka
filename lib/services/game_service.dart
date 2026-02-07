import 'dart:math';

import 'package:matem_appka/const/game.dart';

/// Single generated math question.
class GameQuestion {
  final int a;
  final int b;
  final MathOperation operation;

  const GameQuestion({
    required this.a,
    required this.b,
    required this.operation,
  });

  int correctAnswer() => GameService.calculateResult(a, b, operation);
}

/// Immutable snapshot of current game state used by the UI.
class GameState {
  final GameMode mode;
  final GameQuestion question;
  final int remainingMistakes;
  final int score;

  const GameState({
    required this.mode,
    required this.question,
    required this.remainingMistakes,
    required this.score,
  });

  GameState copyWith({
    GameMode? mode,
    GameQuestion? question,
    int? remainingMistakes,
    int? score,
  }) {
    return GameState(
      mode: mode ?? this.mode,
      question: question ?? this.question,
      remainingMistakes: remainingMistakes ?? this.remainingMistakes,
      score: score ?? this.score,
    );
  }
}

/// Result of submitting an answer.
enum AnswerOutcome {
  correct,
  incorrect,
  gameOver,
}

/// Game logic: generating questions, validating answers, updating score/mistakes.
///
/// UI should own user input string and timer/dialogs.
class GameService {
  final Random _random;

  // Was `late` and could throw during first build before start() is called.
  GameState? _state;

  GameService({Random? random}) : _random = random ?? Random();

  bool get hasState => _state != null;

  GameState get state {
    final s = _state;
    assert(
      s != null,
      'GameService.state was accessed before start() initialized it.',
    );
    return s!;
  }

  /// Initializes state for given [mode] and generates the first question.
  void start({required GameMode mode}) {
    const initialMistakes = 3;
    _state = GameState(
      mode: mode,
      question: _generateQuestion(),
      remainingMistakes: initialMistakes,
      score: 0,
    );
  }

  /// Generates and sets a new question.
  void nextQuestion() {
    final current = _state;
    if (current == null) return;
    _state = current.copyWith(question: _generateQuestion());
  }

  /// Submits [answer]. Returns outcome and updates internal state.
  ///
  /// Scoring & mistakes follow the previous UI behavior:
  /// - correct: +1 score for modes other than practice
  /// - incorrect: decrement remainingMistakes only for GameMode.play
  ///   and return gameOver when it would reach 0.
  AnswerOutcome submitAnswer(int? answer) {
    final current = _state;
    if (current == null) {
      // If UI calls submit before start(), treat as incorrect but don't crash.
      return AnswerOutcome.incorrect;
    }

    final correct = current.question.correctAnswer();
    if (answer != null && answer == correct) {
      if (current.mode != GameMode.practice) {
        _state = current.copyWith(score: current.score + 1);
      }
      return AnswerOutcome.correct;
    }

    if (current.mode == GameMode.play) {
      if (current.remainingMistakes <= 1) {
        // Do not go below 0; preserve old behavior: game over triggers at 1.
        _state = current.copyWith(remainingMistakes: 0);
        return AnswerOutcome.gameOver;
      }
      _state = current.copyWith(remainingMistakes: current.remainingMistakes - 1);
    }

    return AnswerOutcome.incorrect;
  }

  GameQuestion _generateQuestion() {
    final op = MathOperation.values[_random.nextInt(MathOperation.values.length)];

    int a;
    int b = 0;

    switch (op) {
      case MathOperation.squareRoot:
        // Generuj liczbę która jest kwadratem (1, 4, 9, 16, 25, 36, 49, 64, 81, 100)
        final base = _random.nextInt(10) + 1; // 1-10
        a = base * base;
        break;
      case MathOperation.cubeRoot:
        // Generuj liczbę która jest sześcianem (1, 8, 27, 64, 125)
        final base = _random.nextInt(5) + 1; // 1-5
        a = base * base * base;
        break;
      case MathOperation.divide:
        // Upewnij się że dzielenie daje wynik całkowity
        final range = mathOperationRanges[op]!;
        b = _random.nextInt(9) + 1; // 1-9 (unikaj dzielenia przez 0)
        final maxQuotient = range.$2 ~/ b;
        final quotient = _random.nextInt(maxQuotient.clamp(1, 10)) + 1;
        a = b * quotient;
        break;
      case MathOperation.power0:
      case MathOperation.power1:
      case MathOperation.power2:
      case MathOperation.power3:
        // Potęgi: tylko liczba A
        a = _random.nextInt(10) + 1; // 1-10
        break;
      default:
        // Standardowe operacje (add, subtract, multiply) - użyj mathOperationRanges
        final range = mathOperationRanges[op];
        if (range != null) {
          final min = range.$1;
          final max = range.$2;
          a = _random.nextInt(max - min + 1) + min;
          b = _random.nextInt(max - min + 1) + min;
        } else {
          a = _random.nextInt(10);
          b = _random.nextInt(10);
        }
    }

    return GameQuestion(a: a, b: b, operation: op);
  }

  /// Public helper so it can be unit tested.
  static int calculateResult(int a, int b, MathOperation op) {
    switch (op) {
      case MathOperation.add:
        return a + b;
      case MathOperation.subtract:
        return a - b;
      case MathOperation.multiply:
        return a * b;
      case MathOperation.divide:
        return b != 0 ? a ~/ b : 0;
      case MathOperation.power0:
        return 1; // a^0 = 1
      case MathOperation.power1:
        return a; // a^1 = a
      case MathOperation.power2:
        return a * a; // a^2
      case MathOperation.power3:
        return a * a * a; // a^3
      case MathOperation.squareRoot:
        return sqrt(a).floor();
      case MathOperation.cubeRoot:
        return pow(a, 1 / 3).round();
    }
  }
}
