enum MathOperation { add, subtract, multiply, divide,power0, power1, power2, power3, squareRoot, cubeRoot }

const mathOperations = {
  MathOperation.add: '+',
  MathOperation.subtract: '-',
  MathOperation.multiply: '×',
  MathOperation.divide: '÷',
  MathOperation.power0: '⁰',
  MathOperation.power1: '¹',
  MathOperation.power2: '²',
  MathOperation.power3: '³',
  MathOperation.squareRoot: '√',
  MathOperation.cubeRoot: '∛',
};

const mathOperationRanges = {
  MathOperation.add: (0, 100),
  MathOperation.subtract: (0, 100),
  MathOperation.multiply: (0, 10),
  MathOperation.divide: (1, 50),
};

enum GameMode { play, timetrial, practice, passplay }

const gameModeNames = {
  GameMode.play: 'Play',
  GameMode.timetrial: 'Time Trial',
  GameMode.practice: 'Practice',
  GameMode.passplay: 'Pass & Play',
};