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
    '⌫',
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

  // Prevent accessing GameService.state before start() runs.
  bool _gameStarted = false;

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
      } else if (button == '⌫') {
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
      if (numberPad.contains('+/-')) {
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

      // No dialog on correct answer: just advance to next question.
      setState(() {
        userAnswer = '';
        _gameService.nextQuestion();
      });
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
          message: 'End of the game',
          subtitle: 'Your score: $score',
          buttonText: 'Back to Home',
          onTap: () {
            _isResultDialogVisible = false;
            gameEnd();
            Navigator.pushNamed(context, '/home');
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

  // Header styling
  static const double _headerHeight = 125;

  Widget _statChip({
    required IconData icon,
    required String value,
    required Color iconColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Slightly more compact on narrow layouts.
        final isNarrow = MediaQuery.sizeOf(context).width < 380;
        final horizontal = isNarrow ? 10.0 : 12.0;
        final vertical = isNarrow ? 8.0 : 10.0;
        final gap = isNarrow ? 8.0 : 10.0;
        // final iconSize = isNarrow ? 18.0 : 20.0;
        final iconSize = 24.0;
        final valueSize = isNarrow ? 24.0 : 26.0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: iconSize),
              SizedBox(width: gap),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prevent value text from overflowing (e.g. long time)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: whiteBoldedText.copyWith(fontSize: valueSize, height: 1.0),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: _headerHeight,
      color: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: StreamBuilder<int>(
            stream: mode == GameMode.practice ? Stream<int>.empty() : timerStream,
            builder: (context, snapshot) {
              // Timed modes: end game when timer ends
              if (mode != GameMode.practice &&
                  snapshot.hasData &&
                  snapshot.data == secondsLeft - 1) {
                Future.microtask(() {
                  gameOver();
                });
              }

              final timeValue = mode == GameMode.practice
                  ? '∞'
                  : _formatRemainingTime(snapshot.data);

              final mistakesValue = mode == GameMode.play
                  ? remainingMistakes.toString()
                  : '∞';

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 26),
                    onPressed: _showExitConfirmDialog,
                    tooltip: 'Exit',
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _statChip(
                            icon: Icons.timer,
                            value: timeValue,
                            iconColor: Colors.white70,
                          ),
                          _statChip(
                            icon: Icons.error,
                            value: mistakesValue,
                            iconColor: Colors.redAccent,
                          ),
                          if (mode != GameMode.practice)
                            _statChip(
                              icon: Icons.star,
                              value: score.toString(),
                              iconColor: Colors.yellow,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Symmetry placeholder (same width as IconButton) so the wrap stays centered.
                  const SizedBox(width: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatRemainingTime(int? elapsedSeconds) {
    final remainingTime = 120 - (elapsedSeconds ?? 0);
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      // LCD-like background
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE7F2E6),
                          const Color(0xFFCFE3CF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                    children: [
                        // Bezel line
                        Container(
                          height: 2,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            Expanded(
                              child: Text(
                            '$numberA ${mathOperations[operation]} $numberB = ',
                                style: segment14TextStyle.copyWith(
                                  color: const Color(0xFF1B2A1B),
                                  letterSpacing: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                          ),
                            ),
                            const SizedBox(width: 4),
                          Container(
                              height: 54,
                              width: 120,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF0F1A0F).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                            ),
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  userAnswer.isEmpty ? '0' : userAnswer,
                                  style: segment7TextStyle.copyWith(
                                    color: const Color(0xFF0F2A0F),
                                    letterSpacing: 2.0,
                                  ),
                                  maxLines: 1,
                                ),
                            ),
                          ),
                        ],
                      ),
                        if (operation == MathOperation.divide) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                          'Give the result without remainder',
                              style: greyTextStyle.copyWith(
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                        ),
                    ],
                      ],
                    ),
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
                        child: numberPad[index],
                        onTap: () => buttonTapped(numberPad[index]),
                        height: numberPad[index] == '=' ? 2.0 : 1.0,
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
