import 'package:flutter/material.dart';
import 'package:matem_appka/services/streak_service.dart'; // Adjust the import based on your project structure

class SummaryPage extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool isGameOver;
  final bool streakExtended;

  const SummaryPage({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.isGameOver,
    required this.streakExtended,
  });

  @override
  Widget build(BuildContext context) {
    final int totalQuestions = correctAnswers + incorrectAnswers;
    final double accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    final streakService = StreakService();

    String message;
    if (accuracy == 100) {
      message = 'Perfect!';
    } else if (accuracy >= 80) {
      message = 'Great Job! 🎉';
    } else if (accuracy >= 50) {
      message = 'Good Effort!';
    } else {
      message = 'Keep Practicing!';
    }

    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              if (isGameOver)
                const Text(
                  'Game Over',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              if (streakExtended)
                const Text(
                  'Streak Extended!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              if (streakExtended) const SizedBox(height: 16),
              Text(
                '${accuracy.toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Correct', correctAnswers.toString(), Colors.green),
                  _buildStatColumn('Incorrect', incorrectAnswers.toString(), Colors.red),
                  _buildStatColumn('Questions', totalQuestions.toString(), Colors.white),
                ],
              ),
              const SizedBox(height: 48),
              _buildXpCard(score),
              const SizedBox(height: 24),
              if (streakExtended) _buildStreakCard(streakService.currentStreak),
              const Spacer(flex: 3),
              _buildBottomButton(context),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildXpCard(int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '+$score XP',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Experience earned',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade800, Colors.amber.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Streak Extended!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentStreak days and counting',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
