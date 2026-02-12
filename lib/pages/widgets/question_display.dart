import 'package:flutter/material.dart';
import 'package:matem_appka/const/game.dart';
import '../../const/colors.dart';

class QuestionDisplay extends StatelessWidget {
  const QuestionDisplay({
    super.key,
    required this.numberA,
    required this.numberB,
    required this.operation,
    required this.userAnswer,
  });

  final int numberA;
  final int numberB;
  final MathOperation operation;
  final String userAnswer;

  // Returns the exponent as a string for power operations, or null for non-power operations.
  String? _getExponent() {
    switch (operation) {
      case MathOperation.power0:
        return '0';
      case MathOperation.power1:
        return '1';
      case MathOperation.power2:
        return '2';
      case MathOperation.power3:
        return '3';
      default:
        return null;
    }
  }

  bool _isPowerOperation() {
    return operation == MathOperation.power0 ||
           operation == MathOperation.power1 ||
           operation == MathOperation.power2 ||
           operation == MathOperation.power3;
  }

  bool _isRootOperation() {
    return operation == MathOperation.squareRoot ||
           operation == MathOperation.cubeRoot;
  }

  Widget _buildQuestionWidget(TextStyle baseStyle) {
    // Dla pierwiastków: symbol przed liczbą (√A, ∛A)
    if (_isRootOperation()) {
      final symbol = mathOperations[operation] ?? '?';
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          '$symbol$numberA = ',
          style: baseStyle,
          maxLines: 1,
        ),
      );
    }

    // Dla potęg: liczba z górnym indeksem (A^n)
    if (_isPowerOperation()) {
      final exponent = _getExponent()!;
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          maxLines: 1,
          text: TextSpan(
            style: baseStyle,
            children: [
              TextSpan(text: '$numberA'),
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text(
                    exponent,
                    style: baseStyle.copyWith(
                      fontSize: (baseStyle.fontSize ?? 24) * 0.6,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: ' = '),
            ],
          ),
        ),
      );
    }

    // Standardowe operacje: A op B =
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        '$numberA ${mathOperations[operation]} $numberB = ',
        style: baseStyle,
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: _buildQuestionWidget(
                  segment14TextStyle.copyWith(
                    color: const Color(0xFF1B2A1B),
                    letterSpacing: 1.2,
                  ),
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
        ],
      ),
    );
  }
}

