import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:matem_appka/const.dart';
import 'package:matem_appka/util/my_button.dart';
import 'package:matem_appka/util/result_message.dart';

import '../model/highscore.dart';

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

  int numberA = 0;
  int numberB = 0;
  MathOperation operation = MathOperation.add;

  int remainingMistakes = 3;
  int score = 0;

  String userAnswer = '';

  int secondsLeft = 121;

  bool isDialogOpen = false;

  void buttonTapped(String button) {
    setState(() {
      if (button == 'C') {
        //clear the answer
        userAnswer = '';
      }else if (button == '+/-') {
        //toggle the sign of the answer
        if (userAnswer.isNotEmpty) {
          if (userAnswer.startsWith('-')) {
            userAnswer = userAnswer.substring(1); // remove leading '-'
          } else {
            userAnswer = '-' + userAnswer; // add leading '-'
          }
        }
      }
      else if (button == 'DEL') {
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

  void checkResult() {
    if (_calculateResult(numberA, numberB, operation) == int.tryParse(userAnswer)) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ResultMessage(
              message: 'Correct!',
              onTap: goToNextQuestion,
              icon: Icons.arrow_forward,
            );
          });
      score++;
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return ResultMessage(
              message: 'Sorry, try again!',
              onTap: goBackToQuestion,
              icon: Icons.rotate_left,
            );
          });
      if(remainingMistakes == 1) gameOver();
      remainingMistakes--;
    }
  }

  void gameOver(){
    showDialog(
        context: context,
      barrierDismissible: false,
        builder: (context) {
          return ResultMessage(
            message: 'Game Over! Your score is $score',
            onTap: () {
              gameEnd();
              Navigator.pushNamed(context, '/home');
            },
            icon: Icons.close,
          );
      },
    );
  }

  void gameEnd(){
      HighScore(username: "You", score: score).save();
  }

  var randomNumber = Random();

  Stream<int> timerStream = Stream.empty();

  void goToNextQuestion(){
    //dissmiss alert dialog
    Navigator.of(context).pop();

    // reset values
    setState(() {
      userAnswer = '';
    });

    //create new question
    numberA = randomNumber.nextInt(10);
    numberB = randomNumber.nextInt(10);
    operation = MathOperation.values[randomNumber.nextInt(MathOperation.values.length)];

  }

  void goBackToQuestion(){
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
    BackButtonInterceptor.add(myInterceptor);
    timerStream = Stream.periodic(const Duration(seconds: 1), (x) => x).take(secondsLeft);
    numberA = randomNumber.nextInt(10);
    numberB = randomNumber.nextInt(10);
    operation = MathOperation.values[randomNumber.nextInt(MathOperation.values.length)];
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurple[300],
        body: Column(
          children: [
            // level progress, player needs 5 correct answers in a row to proceed to a next level
            Container(
              height: 160,
              color: Colors.deepPurple,
              child: Center(
                child: StreamBuilder<int>(
                  stream: timerStream,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        topBarElement(buildRemainingTimeText(snapshot.data), Icons.timer, Colors.white70),
                        topBarElement(
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                begin: const Offset(0, -1.5), // New text starts from above
                                end: const Offset(0, 0),   // Current text moves downward
                                ).animate(animation),
                                child: child,
                              );},
                              child: Text(
                                remainingMistakes.toString(),
                                key: ValueKey<int>(remainingMistakes),
                                style: whiteBoldedText.copyWith(color: Colors.white), // Ensure text color is visible
                              )
                          ),
                          Icons.cancel,
                          Colors.redAccent,
                        ),
                        topBarElement(
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(scale: animation, child: child);
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
                child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$numberA ${mathOperations[operation]} $numberB = ', style: whiteTextStyle),
                              Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[400],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                    child: Text(userAnswer, style: whiteTextStyle)),
                              )
                            ],
                          ),
                          Text('Give the result without remainder', style: greyTextStyle.copyWith(fontSize: 18)),
                        ],
                      ),
                    ))),
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
                            onTap: () => buttonTapped(numberPad[index]));
                      }),
                ))
          ],
        ));
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
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isDialogOpen) return true; // Prevent opening multiple dialogs

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
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).maybePop(); // Exit the page
              },
              child: const Text("Exit"),
            ),
          ],
        );
      },
    ).then((_) {
      isDialogOpen = false; // Ensure flag is reset when dialog is dismissed
    });

    return true; // Prevent default back button behavior
  }

  int _calculateResult(int a, int b, MathOperation op) {
    switch (op) {
      case MathOperation.add:
        return a + b;
      case MathOperation.subtract:
        return a - b;
      case MathOperation.multiply:
        return a * b;
      case MathOperation.divide:
        return b != 0 ? a ~/ b : 0;
      default:
        return 0;
    }
  }
}
