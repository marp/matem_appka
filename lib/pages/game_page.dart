import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matem_appka/const/game.dart';
import 'package:matem_appka/util/my_button.dart';
import 'package:matem_appka/util/result_message.dart';
import 'package:matem_appka/services/audio_service.dart';
import 'package:matem_appka/services/xp_service.dart';
import 'package:matem_appka/services/activity_service.dart';
import 'package:matem_appka/services/game_service.dart';

import '../const/colors.dart';
import '../model/game_session.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> numberPad = [
    '7',
    '8',
    '9',
    'C',
    '4',
    '5',
    '6',
    'DEL',
    '1',
    '2',
    '3',
    '=',
    '0',
    '+/-',
  ];

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

  int get numberA => _gameService.state.question.a;
  int get numberB => _gameService.state.question.b;
  MathOperation get operation => _gameService.state.question.operation;

  int get remainingMistakes => _gameService.state.remainingMistakes;
  int get score => _gameService.state.score;

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
            userAnswer = '-' + userAnswer; // add leading '-'
          }
        }
      } else if (button == 'DEL') {
        //delete the last character
        if (userAnswer.isNotEmpty) {
          userAnswer = userAnswer.substring(0, userAnswer.length - 1);
        }
      } else if (button == '=') {
        checkResult();
      } else if (userAnswer.length < 3) {
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
      if (numberPad.contains(keyLabel)) {
        buttonTapped(keyLabel);
        return KeyEventResult.handled;
      }
    }

    // Backspace => DEL
    if (logicalKey == LogicalKeyboardKey.backspace) {
      buttonTapped('DEL');
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
      if (numberPad.contains('+/-')) {
        buttonTapped('+/-');
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void checkResult() {
    final outcome = _gameService.submitAnswer(int.tryParse(userAnswer));

    if (outcome == AnswerOutcome.correct) {
      AudioService().playCorrectSound();
      _isResultDialogVisible = true;
      _onResultDialogConfirm = () {
        _isResultDialogVisible = false;
        goToNextQuestion();
      };
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ResultMessage(
            message: 'Correct!',
            onTap: () {
              _isResultDialogVisible = false;
              goToNextQuestion();
            },
            icon: Icons.arrow_forward,
          );
        },
      );

      // Score is updated in GameService.
      setState(() {});
      return;
    }

    // Incorrect or GameOver
    AudioService().playIncorrectSound();

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
      builder: (context) {
        return ResultMessage(
          message: 'Sorry, try again!',
          onTap: () {
            _isResultDialogVisible = false;
            goBackToQuestion();
          },
          icon: Icons.rotate_left,
        );
      },
    );

    // remainingMistakes may have changed in GameService.
    setState(() {});
  }

  void gameOver() {
    // Play game over sound when the game ends
    AudioService().playGameOverSound();
    _isResultDialogVisible = true;
    _onResultDialogConfirm = () {
      _isResultDialogVisible = false;
      gameEnd();
      Navigator.pushNamed(context, '/home');
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ResultMessage(
          message: 'Game Over! Your score is $score',
          onTap: () {
            _isResultDialogVisible = false;
            gameEnd();
            Navigator.pushNamed(context, '/home');
          },
          icon: Icons.close,
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

  void goToNextQuestion() {
    //dissmiss alert dialog
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // reset values
    setState(() {
      userAnswer = '';
      _gameService.nextQuestion();
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

    // Delay to get context for ModalRoute
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['mode'] != null && args['mode'] is GameMode) {
        setState(() {
          mode = args['mode'] as GameMode;
        });
      }

      _gameService.start(mode: mode);

      if (mode == GameMode.practice) {
        timerStream = Stream.empty();
      } else {
        // Start the timer and play countdown sound for timed mode
        timerStream = Stream.periodic(const Duration(seconds: 1), (x) => x).take(secondsLeft);
        AudioService().playCountdownSound();
      }

      // After first frame, grab focus so physical keyboard works immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _keyboardFocusNode.requestFocus();
        }
      });

      // Ensure initial question is shown.
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
          body: Column(
            children: [
              Container(
                height: 160,
                color: Colors.deepPurple,
                child: Center(
                  child: mode == GameMode.practice
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                              onPressed: _showExitConfirmDialog,
                              tooltip: 'Exit',
                            ),
                            topBarElement(
                              Text('∞', style: whiteBoldedText),
                              Icons.error,
                              Colors.redAccent,
                            ),
                            topBarElement(
                              Text('-', style: whiteBoldedText),
                              Icons.star,
                              Colors.yellow,
                            ),
                          ],
                        )
                      : StreamBuilder<int>(
                          stream: timerStream,
                          builder: (context, snapshot) {
                            // Check if the timer has ended
                            if (snapshot.hasData &&
                                snapshot.data == secondsLeft - 1) {
                              // End the game if time is up
                              Future.microtask(() {
                                // if (Navigator.canPop(context)) Navigator.of(context).popUntil((route) => route.isFirst);
                                gameOver();
                            });
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                                onPressed: _showExitConfirmDialog,
                                tooltip: 'Exit',
                              ),
                              topBarElement(
                                  buildRemainingTimeText(snapshot.data),
                                  Icons.timer,
                                  Colors.white70),
                              topBarElement(
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  transitionBuilder:
                                      (child, animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, -1.5),
                                        end: const Offset(0, 0),
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    mode == GameMode.timetrial ? '∞' : remainingMistakes.toString(),
                                    key: ValueKey<int>(remainingMistakes),
                                    style: whiteBoldedText.copyWith(
                                        color: Colors.white),
                                  ),
                                ),
                                Icons.error,
                                Colors.redAccent,
                              ),
                              topBarElement(
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  transitionBuilder:
                                      (child, animation) {
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                  child: Text(
                                    score.toString(),
                                    key: ValueKey<int>(score),
                                    style: whiteBoldedText,
                                  ),
                                ),
                                Icons.star,
                                Colors.yellow,
                              ),
                            ],
                          );
                        },
                      ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$numberA ${mathOperations[operation]} $numberB = ',
                            style: whiteTextStyle,
                          ),
                          Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(userAnswer, style: whiteTextStyle),
                            ),
                          ),
                        ],
                      ),
                      if (operation == MathOperation.divide)
                        Text(
                          'Give the result without remainder',
                          style: greyTextStyle,
                        ),
                    ],
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
                      return MyButton(
                        child: numberPad[index],
                        onTap: () => buttonTapped(numberPad[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRemainingTimeText(int? elapsedSeconds) {
    int remainingTime = 120 - (elapsedSeconds ?? 0);
    int minutes = remainingTime ~/ 60;
    int seconds = remainingTime % 60;

    return Text(
      '$minutes:${seconds.toString().padLeft(2, '0')}',
      style: whiteBoldedText,
    );
  }

  Widget topBarElement(Widget child, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(width: 8),
        child,
      ],
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    _keyboardFocusNode.dispose();
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
                Navigator.pushNamed(context, '/home');
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
