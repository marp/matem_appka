import 'package:flutter/material.dart';

var normalText = const TextStyle(
    fontSize: 18,
    color: Colors.black
);

var whiteNormalText = const TextStyle(
    fontSize: 18,
    color: Colors.white
);

var whiteTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 32,
    color: Colors.white
);

var whiteBoldedText = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Colors.white
);

var greyTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: Colors.white70
);

enum MathOperation { add, subtract, multiply, divide, power, root }

const mathOperations = {
  MathOperation.add: '+',
  MathOperation.subtract: '-',
  MathOperation.multiply: '×',
  MathOperation.divide: '÷',
  MathOperation.power: '^',
  MathOperation.root: '√',
};

enum GameMode { play, timetrial, practice, passplay }

const gameModeNames = {
  GameMode.play: 'Play',
  GameMode.timetrial: 'Time Trial',
  GameMode.practice: 'Practice',
  GameMode.passplay: 'Pass & Play',
};