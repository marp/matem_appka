import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const.dart';
import '../util/streak_service.dart';
import '../util/xp_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _currentXp = 0;
  bool _isStreakPressed = false;
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streakService = StreakService();
    final xpService = XpService();
    setState(() {
      _currentStreak = streakService.currentStreak;
      _bestStreak = streakService.bestStreak;
      _currentXp = xpService.currentXp;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 80;

    return Container(
      color: Color(0xFF272837),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mat',
                        style: TextStyle(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontSize: 42,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'em',
                        style: TextStyle(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontSize: 42,
                          foreground:
                              Paint()
                                ..color = Colors.white
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 0.1,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'App',
                        style: TextStyle(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontSize: 42,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ka',
                        style: TextStyle(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontSize: 42,
                          foreground:
                              Paint()
                                ..color = Colors.white
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isStreakPressed = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isStreakPressed = false;
                        });
                        Navigator.pushNamed(context, '/activity');
                      },
                      onTapCancel: () {
                        setState(() {
                          _isStreakPressed = false;
                        });
                      },
                      child: AnimatedScale(
                        scale: _isStreakPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.whatshot, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Streak: $_currentStreak days',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_border, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'XP: $_currentXp',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  circButton(Icons.info, () {
                    Navigator.pushNamed(context, '/about');
                  }),
                  circButton(Icons.sports_score_sharp, () {
                    Navigator.pushNamed(context, '/highScores');
                  }),
                  // circButton(Icons.lightbulb, () {
                  // }),
                  circButton(Icons.settings, () {
                    Navigator.pushNamed(context, '/settings');
                  }),
                ],
              ),
              Wrap(
                runSpacing: 16,
                children: [
                  modeButton(
                    'Play',
                    'Elevate your level',
                    Icons.play_arrow,
                    Color(0xFF2F80ED),
                    width,
                    () {
                      Navigator.pushNamed(context, '/game', arguments: {'mode': GameMode.play});
                    },
                  ),
                  modeButton(
                    'Time Trial',
                    'Race against the clock',
                    Icons.timer_outlined,
                    Color(0xFFDF1D5A),
                    width,
                    () {
                      Navigator.pushNamed(context, '/game', arguments: {'mode': GameMode.timetrial});
                    },
                  ),
                  modeButton(
                    'Practice',
                    'Practice alone',
                    Icons.check_circle,
                    Color(0xFF45D280),
                    width,
                    () {
                      Navigator.pushNamed(context, '/game', arguments: {'mode': GameMode.practice});
                    },
                  ),
                  modeButton(
                    'Pass & Play',
                    'Challenge your friends',
                    Icons.people,
                    Color(0xFFFF8306),
                    width,
                    () {
                      Navigator.pushNamed(context, '/game', arguments: {'mode': GameMode.passplay});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding circButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: RawMaterialButton(
        onPressed: onTap,
        fillColor: Colors.white,
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 45, minWidth: 45),
        child: Icon(icon, color: Color(0xFF272837), size: 26),
      ),
    );
  }

  GestureDetector modeButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    double width,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        fontFamily: 'Manrope',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}