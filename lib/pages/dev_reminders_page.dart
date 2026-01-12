import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Map<Permission, PermissionStatus> _permissionStatus = {};
  DateTime? _nextReminderDate;
  List<PendingNotificationRequest> _pendingNotifications = [];

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
    _loadNextReminderDate();
    _loadPendingNotifications();
  }

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    if (mounted) {
      setState(() {
        _pendingNotifications = pending;
      });
    }
  }

  Future<void> _loadNextReminderDate() async {
    final nextDate = await _notificationService.getNextReminderDate();
    if (mounted) {
      setState(() {
        _nextReminderDate = nextDate;
      });
    }
  }

  Future<void> _loadPermissionStatus() async {
    try {
      final status = await _notificationService.getPermissionsStatus();
      if (mounted) {
        setState(() {
          _permissionStatus = status;
        });
      }
    } catch (e, s) {
      debugPrint('Error while checking notification permission: $e\n$s');
      if (mounted) {
        setState(() {
          _permissionStatus = {};
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
    _loadPendingNotifications();
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
    _loadPendingNotifications();
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
      // Refresh the next reminder date after cancelling
      await _loadNextReminderDate();
      await _loadPendingNotifications();
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

  String _formatDuration(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
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
            const SizedBox(height: 16),
            const Text('Next scheduled lesson reminder:'),
            if (_nextReminderDate == null)
              const Text('Reminders are off or no reminder scheduled.')
            else
              StreamBuilder<DateTime>(
                stream: Stream<DateTime>.periodic(
                  const Duration(seconds: 1),
                  (_) => DateTime.now(),
                ),
                builder: (context, _) {
                  final now = DateTime.now();
                  final diff = _nextReminderDate!.difference(now);
                  final safe = diff.isNegative ? Duration.zero : diff;

                  return Text(
                    '${_nextReminderDate!.toIso8601String()} (local time) \u2014 in ${_formatDuration(safe)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
            Row(
              children: [
                const Text('Permissions: '),
                if (_permissionStatus.isEmpty)
                  const Text('checking...',
                      style: TextStyle(color: Colors.orange))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _permissionStatus.entries.map((entry) {
                      final permission = entry.key;
                      final status = entry.value;
                      return Text(
                        '${permission.toString().split('.').last}: ${status.name}',
                        style: TextStyle(
                          color: status.isGranted ? Colors.green : Colors.red,
                        ),
                      );
                    }).toList(),
                  ),
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
            const SizedBox(height: 16),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Pending notifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPendingNotifications,
                ),
              ],
            ),
            if (_pendingNotifications.isEmpty)
              const Text('No pending notifications.')
            else
              for (final p in _pendingNotifications)
                StreamBuilder<DateTime>(
                  stream: Stream<DateTime>.periodic(
                    const Duration(seconds: 1),
                    (_) => DateTime.now(),
                  ),
                  builder: (context, _) {
                    final scheduledTime = p.payload;
                    if (scheduledTime == null) {
                      return Text(
                        'ID ${p.id}: "${p.title}" (no schedule date)',
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    final now = DateTime.now();
                    final scheduledDt = DateTime.tryParse(scheduledTime);
                    final diff = (scheduledDt?.toLocal() ?? now).difference(now);
                    final safe = diff.isNegative ? Duration.zero : diff;

                    return Text(
                      'ID ${p.id}: "${p.title}" at ${scheduledTime} \u2014 in ${_formatDuration(safe)}',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
