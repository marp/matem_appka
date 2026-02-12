import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matem_appka/const/game.dart';
import 'package:matem_appka/util/calc_button.dart';
import 'package:matem_appka/util/result_message.dart';
import 'package:matem_appka/services/audio_service.dart';
import 'package:matem_appka/services/xp_service.dart';
import 'package:matem_appka/services/activity_service.dart';
import 'package:matem_appka/services/game_service.dart';
import 'package:matem_appka/pages/widgets/game_header.dart';
import 'package:matem_appka/pages/widgets/question_display.dart';
import 'package:matem_appka/model/calc_button_model.dart';

import '../model/game_session.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late List<CalcButtonModel> numberPad;

  // NOTE: state for question/score/mistakes is now in GameService.
  // Removed old fields: numberA, numberB, operation, remainingMistakes, score.

  String userAnswer = '';

  int secondsLeft = 121;

  bool isDialogOpen = false;

  GameMode mode = GameMode.play; // default

  final FocusNode _keyboardFocusNode = FocusNode();

  // Tracks whether a result-related dialog is visible and how to confirm it.
  bool _isResultDialogVisible = false;
  VoidCallback? _onResultDialogConfirm;

  // Game domain logic extracted from UI.
  late final GameService _gameService;

  // Prevent accessing GameService.state before start() runs.
  bool _gameStarted = false;

  // Animacja błysku przy poprawnej odpowiedzi
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  Color _flashColor = Colors.green;

  int get numberA => _gameService.state.question.a;
  int get numberB => _gameService.state.question.b;
  MathOperation get operation => _gameService.state.question.operation;

  int get remainingMistakes => _gameService.state.remainingMistakes;
  int get score => _gameService.state.score;

  void _initializeButtons() {
    // Sprawdź czy wynik jest ujemny
    final correctAnswer = _gameService.state.question.correctAnswer();
    final bool isNegative = correctAnswer < 0;

    numberPad = [
      CalcButtonModel(
        text: '7',
        type: ButtonType.number,
        onTap: () => buttonTapped('7'),
      ),
      CalcButtonModel(
        text: '8',
        type: ButtonType.number,
        onTap: () => buttonTapped('8'),
      ),
      CalcButtonModel(
        text: '9',
        type: ButtonType.number,
        onTap: () => buttonTapped('9'),
      ),
      CalcButtonModel(
        text: 'C',
        type: ButtonType.clear,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
        fontWeight: FontWeight.bold,
        onTap: () => buttonTapped('C'),
      ),
      CalcButtonModel(
        text: '4',
        type: ButtonType.number,
        onTap: () => buttonTapped('4'),
      ),
      CalcButtonModel(
        text: '5',
        type: ButtonType.number,
        onTap: () => buttonTapped('5'),
      ),
      CalcButtonModel(
        text: '6',
        type: ButtonType.number,
        onTap: () => buttonTapped('6'),
      ),
      CalcButtonModel(
        text: '⌫',
        type: ButtonType.action,
        backgroundColor: Colors.orange[600],
        textColor: Colors.white,
        fontWeight: FontWeight.bold,
        onTap: () => buttonTapped('⌫'),
      ),
      CalcButtonModel(
        text: '1',
        type: ButtonType.number,
        onTap: () => buttonTapped('1'),
      ),
      CalcButtonModel(
        text: '2',
        type: ButtonType.number,
        onTap: () => buttonTapped('2'),
      ),
      CalcButtonModel(
        text: '3',
        type: ButtonType.number,
        onTap: () => buttonTapped('3'),
      ),
      CalcButtonModel(
        text: '=',
        type: ButtonType.operation,
        backgroundColor: Colors.deepPurple[700],
        textColor: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        height: 2.0,
        onTap: () => buttonTapped('='),
      ),
      CalcButtonModel(
        text: '0',
        type: ButtonType.number,
        onTap: () => buttonTapped('0'),
      ),
      // Dodaj przycisk +/- tylko jeśli wynik jest ujemny
      if (isNegative)
        CalcButtonModel(
          text: '+/-',
          type: ButtonType.action,
          backgroundColor: Colors.grey[700],
          textColor: Colors.white,
          fontSize: 16,
          onTap: () => buttonTapped('+/-'),
        ),
    ];
  }

  void buttonTapped(String button) {
    setState(() {
      if (button == 'C') {
        //clear the answer
        userAnswer = '';
      } else if (button == '+/-') {
        //toggle the sign of the answer
        if (userAnswer.isNotEmpty) {
          if (userAnswer.startsWith('-')) {
            userAnswer = userAnswer.substring(1); // remove leading '-'
          } else {
            userAnswer = '-$userAnswer'; // add leading '-'
          }
        }
      } else if (button == '⌫') {
        //delete the last character
        if (userAnswer.isNotEmpty) {
          userAnswer = userAnswer.substring(0, userAnswer.length - 1);
        }
      } else if (button == '=') {
        checkResult();
      } else if (userAnswer.length < 4) {
        //maximum of 3 numbers can be inputted
        if (userAnswer == '0') {
          userAnswer = button; // replace leading zero
        } else {
          userAnswer += button;
        }
      }
    });
  }

  // Handle physical keyboard events and map them to virtual keypad buttons
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final logicalKey = event.logicalKey;
    final keyLabel = logicalKey.keyLabel;

    // If any result dialog (correct / incorrect / game over) is visible,
    // allow Enter, Numpad Enter or Space to trigger its confirm action.
    if (_isResultDialogVisible &&
        (logicalKey == LogicalKeyboardKey.enter ||
         logicalKey == LogicalKeyboardKey.numpadEnter ||
         logicalKey == LogicalKeyboardKey.space)) {
      final callback = _onResultDialogConfirm;
      if (callback != null) {
        callback();
      }
      return KeyEventResult.handled;
    }

    if (isDialogOpen) return KeyEventResult.handled;

    // Digits 0-9 (also from numpad) => same as pressing number buttons
    if (keyLabel.length == 1 && '0123456789'.contains(keyLabel)) {
      final buttonExists = numberPad.any((button) => button.text == keyLabel);
      if (buttonExists) {
        buttonTapped(keyLabel);
        return KeyEventResult.handled;
      }
    }

    // Backspace => ⌫
    if (logicalKey == LogicalKeyboardKey.backspace) {
      buttonTapped('⌫');
      return KeyEventResult.handled;
    }

    // Enter / Numpad Enter => '='
    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      buttonTapped('=');
      return KeyEventResult.handled;
    }

    // Minus / numpad subtract => '+/-'
    if (logicalKey == LogicalKeyboardKey.minus ||
        logicalKey == LogicalKeyboardKey.numpadSubtract ||
        keyLabel == '-') {
      final buttonExists = numberPad.any((button) => button.text == '+/-');
      if (buttonExists) {
        buttonTapped('+/-');
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void checkResult() {
    // Avoid handling answers while any dialog is visible.
    if (isDialogOpen || _isResultDialogVisible) return;

    final outcome = _gameService.submitAnswer(int.tryParse(userAnswer));

    if (outcome == AnswerOutcome.correct) {
      AudioService().playCorrectSound();

      // Uruchom animację błysku (zielony)
      _flashColor = Colors.green;
      _flashController.forward(from: 0.0);

      // No dialog on correct answer: just advance to next question.
      setState(() {
        userAnswer = '';
        _gameService.nextQuestion();
        _initializeButtons(); // Zaktualizuj przyciski dla nowego pytania
      });
      return;
    }

    // Incorrect or GameOver
    AudioService().playIncorrectSound();

    // Uruchom animację błysku (czerwony)
    _flashColor = Colors.red;
    _flashController.forward(from: 0.0);

    if (outcome == AnswerOutcome.gameOver) {
      timerStream = Stream.empty();
      // ensure UI picks up remainingMistakes/score changes
      setState(() {});
      gameOver();
      return;
    }

    _isResultDialogVisible = true;
    _onResultDialogConfirm = () {
      _isResultDialogVisible = false;
      goBackToQuestion();
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ResultMessage(
          message: 'Incorrect Answer',
          subtitle: 'Relax and try again!',
          buttonText: 'Ok',
          onTap: () {
            _isResultDialogVisible = false;
            goBackToQuestion();
          },
          icon: Icons.rotate_left,
          accentColor: Colors.orangeAccent,
        );
      },
    );

    // remainingMistakes may have changed in GameService.
    setState(() {});
  }

  void gameOver() {
    if (_isGameOver) return; // Zapobiegaj wielokrotnemu wywołaniu
    _isGameOver = true;

    // Play game over sound when the game ends
    AudioService().playGameOverSound();
    _isResultDialogVisible = true;
    _onResultDialogConfirm = () {
      _isResultDialogVisible = false;
      gameEnd();
      Navigator.pushReplacementNamed(context, '/home');
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ResultMessage(
          message: 'End of the game',
          subtitle: 'Your score: $score',
          buttonText: 'Back to Home',
          onTap: () {
            _isResultDialogVisible = false;
            gameEnd();
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: Icons.hourglass_bottom,
          accentColor: Colors.yellow
        );
      },
    );
  }

  void gameEnd() async {
    if (mode != GameMode.practice) {
      // HighScore(username: "You", score: score).save();
      await XpService().addXp(score);
      await ActivityService().addSession(
        GameSession(
          playedAt: DateTime.now(),
          gameType: mode.toString().split('.').last,
          xpEarned: score,
          score: score,
          durationSeconds: 120,
          mistakes: 3 - remainingMistakes,
        ),
      );
    }
  }

  Stream<int> timerStream = Stream.empty();

  // Flaga do śledzenia czy gra się zakończyła
  bool _isGameOver = false;

  void goToNextQuestion() {
    //dissmiss alert dialog
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // reset values
    setState(() {
      userAnswer = '';
      _gameService.nextQuestion();
      _initializeButtons(); // Zaktualizuj przyciski dla nowego pytania
    });
  }

  void goBackToQuestion() {
    //dissmiss alert dialog
    Navigator.of(context).pop();

    // reset values
    setState(() {
      userAnswer = '';
    });
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor, context: context);

    _gameService = GameService();


    // Inicjalizacja animacji błysku
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
    _flashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashController.reverse();
      }
    });

    // After first frame, grab focus so physical keyboard works immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_gameStarted) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['mode'] is GameMode) {
      mode = args['mode'] as GameMode;
    }

    _gameService.start(mode: mode);

    // Inicjalizacja przycisków po start() żeby state był dostępny
    _initializeButtons();

    if (mode == GameMode.practice) {
      timerStream = Stream.empty();
    } else {
      // Start the timer and play countdown sound for timed mode
      timerStream = Stream.periodic(const Duration(seconds: 1), (x) => x).take(secondsLeft);
      AudioService().playCountdownSound();
    }

    _gameStarted = true;
    // Make sure first question shows.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted || !_gameService.hasState) {
      return const Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmDialog();
      },
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.deepPurple[300],
          body: Stack(
            children: [
              Column(
                children: [
                  GameHeader(
                    mode: mode,
                    timerStream: timerStream,
                    secondsLeft: secondsLeft,
                    remainingMistakes: remainingMistakes,
                    score: score,
                    onExit: _showExitConfirmDialog,
                    onTimeExpired: gameOver,
                  ),
                  Expanded(
                    child: Center(
                      child: QuestionDisplay(
                        numberA: numberA,
                        numberB: numberB,
                        operation: operation,
                        userAnswer: userAnswer,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GridView.builder(
                        itemCount: numberPad.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4),
                        itemBuilder: (context, index) {
                          return CalcButton(
                            buttonModel: numberPad[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // Błysk przy odpowiedzi (zielony = poprawna, czerwony = błędna)
              AnimatedBuilder(
                animation: _flashAnimation,
                builder: (context, child) {
                  return IgnorePointer(
                    child: Container(
                      color: _flashColor.withValues(alpha: _flashAnimation.value * 0.4),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    _keyboardFocusNode.dispose();
    _flashController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    _showExitConfirmDialog();
    return true; // Prevent default back button behavior
  }

  void _showExitConfirmDialog() {
    if (isDialogOpen) return; // Prevent opening multiple dialogs

    // If a result dialog is currently visible (Correct/Incorrect/GameOver),
    // don't stack another dialog on top.
    if (_isResultDialogVisible) return;

    isDialogOpen = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Exit"),
          content: const Text("Do you really want to exit?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _isGameOver = true; // Oznacz grę jako zakończoną
                Navigator.of(context).pop(); // Zamknij dialog
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text("Exit"),
            ),
          ],
        );
      },
    ).then((_) {
      isDialogOpen = false; // Ensure flag is reset when dialog is dismissed
    });
  }
}
