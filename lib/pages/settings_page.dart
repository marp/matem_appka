import 'package:flutter/material.dart';
import 'package:matem_appka/util/audio_service.dart';
import 'package:matem_appka/util/xp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isMusicEnabled = true;
  bool isSoundEffectsEnabled = true;

  Future<void> _loadSettings() async {
    final audioService = AudioService();
    setState(() {
      isMusicEnabled = audioService.isMusicEnabled;
      isSoundEffectsEnabled = audioService.isSoundEffectsEnabled;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _resetScores() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset scoreboard'),
          content: const Text('Are you sure you want to clear all high scores? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('highscores');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('High scores have been reset.')),
      );
    }
  }

  Future<void> _resetXp() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset XP'),
          content: const Text('Are you sure you want to reset your experience points?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await XpService().resetXp();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('XP has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Music'),
              value: isMusicEnabled,
              onChanged: (value) async {
                setState(() {
                  isMusicEnabled = value;
                });
                await AudioService().setMusicEnabled(value);
              },
            ),
            SwitchListTile(
              title: const Text('Sound Effects'),
              value: isSoundEffectsEnabled,
              onChanged: (value) async {
                setState(() {
                  isSoundEffectsEnabled = value;
                });
                await AudioService().setSoundEffectsEnabled(value);
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.redAccent),
              title: const Text('Reset scoreboard'),
              subtitle: const Text('Clear all saved high scores'),
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: _resetScores,
            ),
            ListTile(
              leading: const Icon(Icons.star_outline, color: Colors.orangeAccent),
              title: const Text('Reset XP'),
              subtitle: const Text('Reset your experience points'),
              textColor: Colors.orangeAccent,
              iconColor: Colors.orangeAccent,
              onTap: _resetXp,
            ),
          ],
        ),
      ),
    );
  }
}
