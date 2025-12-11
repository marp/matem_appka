import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/colors.dart';
import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      SizedBox(height: 16),
                      // Logo
                      Center(
                        child: Image(
                          image: AssetImage('assets/images/logo.png'),
                          width: 120,
                          height: 120,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Heading
                      Text(
                        'Welcome to Matem Appka!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This app helps you practice math, track your progress, and stay motivated with daily streaks.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      // Game modes section
                      Text(
                        'Game modes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _OnboardingRow(
                        icon: Icons.play_arrow,
                        title: 'Play',
                        description:
                            'Classic mode. You have 2 minutes to solve as many tasks as you can, the difficulty gradually increases and you can make at most 3 mistakes.',
                      ),
                      _OnboardingRow(
                        icon: Icons.timer_outlined,
                        title: 'Time Trial',
                        description:
                            'Race against the clock with the same rules as Play mode, but mistakes are not counted – focus on answering as many questions as you can before time runs out.',
                      ),
                      _OnboardingRow(
                        icon: Icons.check_circle_outline,
                        title: 'Practice',
                        description:
                            'Relaxed mode for focused learning. There is no timer and mistakes or points are not counted, so you can try harder questions and experiment without any pressure.',
                      ),
                      _OnboardingRow(
                        icon: Icons.people_alt_outlined,
                        title: 'Pass & Play',
                        description:
                            'Local multiplayer mode. Each player plays their own round on the same device, then passes the phone to the next player. Everyone tries to get the highest score in their round.',
                      ),
                      SizedBox(height: 24),
                      Divider(height: 1, color: Colors.white24),
                      SizedBox(height: 24),
                      // Progress section
                      Text(
                        'Progress & motivation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Points explanation
                      _OnboardingRow(
                        icon: Icons.star_border,
                        title: 'Points',
                        description:
                            'In each game you earn points based on your answers. Higher score in a single game means more points.',
                      ),
                      // Mistakes explanation
                      _OnboardingRow(
                        icon: Icons.error_outline,
                        title: 'Mistakes',
                        description:
                            'Mistakes are tracked per game mode. Fewer mistakes mean better performance and more points.',
                      ),
                      // XP explanation
                      _OnboardingRow(
                        icon: Icons.bolt_outlined,
                        title: 'XP',
                        description:
                            'Points from your games are converted into XP. XP shows your overall long-term progress in Matem Appka.',
                      ),
                      // Streak explanation
                      _OnboardingRow(
                        icon: Icons.whatshot,
                        title: 'Streak',
                        description:
                            'Play every day to build your streak. Longer streaks mean better habits and more consistent progress.',
                      ),
                      SizedBox(height: 24),
                      Divider(height: 1, color: Colors.white24),
                      SizedBox(height: 24),
                      // Tips section
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _OnboardingRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Daily reminders',
                        description:
                            'Enable daily lesson reminders in Settings to help you remember your practice sessions.',
                      ),
                      _OnboardingRow(
                        icon: Icons.insights_outlined,
                        title: 'Track progress',
                        description:
                            'See your daily activity, XP growth, and results in the Activity screen.',
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Fixed bottom button with improved styling
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _completeOnboarding(context),
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}