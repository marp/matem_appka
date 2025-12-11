import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// Developer page to manually trigger local notifications for testing.
/// This screen should only be used in development / debug builds.
class DevRemindersPage extends StatefulWidget {
  const DevRemindersPage({super.key});

  @override
  State<DevRemindersPage> createState() => _DevRemindersPageState();
}

class _DevRemindersPageState extends State<DevRemindersPage> {
  final TextEditingController _delayController =
      TextEditingController(text: '5');
  String _lastActionLog = 'No actions yet';
  bool _isSending = false;
  bool? _hasPermission;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissionStatus() async {
    try {
      final granted = await _notificationService.hasPermission();
      if (mounted) {
        setState(() {
          _hasPermission = granted;
        });
      }
    } catch (e, s) {
      debugPrint('Error while checking notification permission: $e\n$s');
      if (mounted) {
        setState(() {
          _hasPermission = null;
        });
      }
    }
  }

  Future<void> _sendImmediateTestNotification() async {
    setState(() {
      _isSending = true;
      _lastActionLog = 'Sending immediate notification...';
    });

    try {
      await _notificationService.showImmediateTestNotification();
      setState(() {
        _lastActionLog =
            'Sent immediate test notification at ${DateTime.now()}';
      });
    } catch (e, s) {
      debugPrint(
        'Error while sending immediate notification: $e\n$s',
      );
      setState(() {
        _lastActionLog = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _scheduleDelayedTestNotification() async {
    final raw = _delayController.text.trim();
    final seconds = int.tryParse(raw);

    if (seconds == null || seconds < 0) {
      setState(() {
        _lastActionLog = 'Invalid delay value: "$raw"';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _lastActionLog = 'Scheduling notification in $seconds s...';
    });

    try {
      await _notificationService
          .scheduleTestNotificationAfter(Duration(seconds: seconds));
      setState(() {
        _lastActionLog =
            'Scheduled test notification in $seconds s (at ${DateTime.now().add(Duration(seconds: seconds))})';
      });
    } catch (e, s) {
      debugPrint('Error while scheduling notification: $e\n$s');
      setState(() {
        _lastActionLog = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _cancelAllNotifications() async {
    setState(() {
      _isSending = true;
      _lastActionLog = 'Cancelling all notifications...';
    });

    try {
      await _notificationService.cancelAll();
      setState(() {
        _lastActionLog =
            'Cancelled all scheduled and active notifications.';
      });
    } catch (e, s) {
      debugPrint('Error while cancelling notifications: $e\n$s');
      setState(() {
        _lastActionLog = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev: Reminders / Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!kDebugMode)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'WARNING: This screen is intended for debug mode only.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const Text(
              'Developer screen for testing notifications (reminders).',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Notification permission: '),
                if (_hasPermission == null)
                  const Text('checking...',
                      style: TextStyle(color: Colors.orange))
                else if (_hasPermission == true)
                  const Text('granted',
                      style: TextStyle(color: Colors.green))
                else
                  const Text('denied', style: TextStyle(color: Colors.red)),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _loadPermissionStatus,
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Immediate test notification'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isSending ? null : _sendImmediateTestNotification,
              child: const Text('Send now'),
            ),
            const SizedBox(height: 24),
            const Text('Scheduled test notification'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Delay (s): '),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _delayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _isSending ? null : _scheduleDelayedTestNotification,
                  child: const Text('Schedule'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _isSending ? null : _cancelAllNotifications,
              child: const Text('Cancel ALL notifications'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text('Last action:'),
            const SizedBox(height: 4),
            Text(
              _lastActionLog,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
