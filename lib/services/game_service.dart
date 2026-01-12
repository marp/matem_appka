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
    final a = _random.nextInt(10);
    final b = _random.nextInt(10);
    final op = MathOperation.values[_random.nextInt(MathOperation.values.length)];
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
      case MathOperation.power:
        // Keep constraints simple (single-digit base/exponent).
        return pow(a, b).toInt();
      case MathOperation.root:
        // Integer square root (floor). For b, we ignore and root 'a'.
        // This keeps the existing enum usable without breaking UI.
        return sqrt(a).floor();
    }
  }
}
