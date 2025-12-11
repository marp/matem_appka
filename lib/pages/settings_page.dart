import 'package:flutter/material.dart';
import 'package:matem_appka/services/audio_service.dart';
import 'package:matem_appka/services/xp_service.dart';
import 'package:matem_appka/services/activity_service.dart';
import 'package:matem_appka/models/reminder_frequency.dart';
import 'package:matem_appka/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isMusicEnabled = true;
  bool isSoundEffectsEnabled = true;
  bool _notificationsEnabled = false;

  Future<void> _loadSettings() async {
    final audioService = AudioService();
    final notificationService = NotificationService();
    final reminderFrequency = await notificationService.loadReminderFrequency();
    setState(() {
      isMusicEnabled = audioService.isMusicEnabled;
      isSoundEffectsEnabled = audioService.isSoundEffectsEnabled;
      _notificationsEnabled = reminderFrequency == ReminderFrequency.everyDay;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _resetUserData() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset user data'),
          content: const Text(
              'Are you sure you want to reset all your data? This will clear your high scores, XP, activity history, audio settings and daily reminders. This cannot be undone.'),
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
      // Clear highscores
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('highscores');

      // Reset XP and activity history
      await XpService().resetXp();
      await ActivityService().resetSessions();

      // Reset audio settings to defaults (both enabled by default)
      final audioService = AudioService();
      await audioService.setMusicEnabled(true);
      await audioService.setSoundEffectsEnabled(true);

      // Reset notifications: turn off daily reminders
      final notificationService = NotificationService();
      await notificationService
          .saveReminderFrequency(ReminderFrequency.off);
      await notificationService
          .scheduleLessonReminders(ReminderFrequency.off);

      if (!mounted) return;

      setState(() {
        isMusicEnabled = audioService.isMusicEnabled;
        isSoundEffectsEnabled = audioService.isSoundEffectsEnabled;
        _notificationsEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All user data has been reset.')),
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
            const Divider(),
            SwitchListTile(
              title: const Text('Daily lesson reminders'),
              subtitle:
                  const Text('Get a notification once a day to take a lesson'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                final notificationService = NotificationService();

                // Użytkownik próbuje włączyć powiadomienia
                if (value) {
                  final granted =
                      await notificationService.ensurePermissionsGranted();

                  if (!granted) {
                    if (!mounted) return;
                    setState(() {
                      _notificationsEnabled = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notifications are disabled. Enable them in system settings to receive daily reminders.',
                        ),
                      ),
                    );
                    return;
                  }
                }

                if (!mounted) return;
                setState(() {
                  _notificationsEnabled = value;
                });

                final frequency =
                    value ? ReminderFrequency.everyDay : ReminderFrequency.off;
                await notificationService.saveReminderFrequency(frequency);
                await notificationService.scheduleLessonReminders(frequency);
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('Reset user data'),
              subtitle: const Text(
                  'Clear all progress, high scores, audio and notification settings'),
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: _resetUserData,
            ),
          ],
        ),
      ),
    );
  }
}
