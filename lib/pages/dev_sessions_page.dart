import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matem_appka/model/game_session.dart';
import 'package:matem_appka/util/activity_service.dart';

class DevSessionsPage extends StatefulWidget {
  const DevSessionsPage({super.key});

  @override
  State<DevSessionsPage> createState() => _DevSessionsPageState();
}

class _DevSessionsPageState extends State<DevSessionsPage> {
  final ActivityService _activityService = ActivityService();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  List<GameSession> get _sessions =>
      _activityService.debugMutableSessions.reversed.toList();

  Future<void> _refresh() async {
    setState(() {});
  }

  Future<void> _confirmDelete(GameSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _activityService.debugMutableSessions.remove(session);
      await _activityService.debugSaveSessions();
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _editSession(GameSession session) async {
    final xpController =
        TextEditingController(text: session.xpEarned.toString());
    final scoreController =
        TextEditingController(text: session.score.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Played at:\n${_dateFormat.format(session.playedAt)}'),
            const SizedBox(height: 12),
            TextField(
              controller: xpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'XP earned'),
            ),
            TextField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Score'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final xp = int.tryParse(xpController.text) ?? session.xpEarned;
      final score = int.tryParse(scoreController.text) ?? session.score;

      final list = _activityService.debugMutableSessions;
      final idx = list.indexOf(session);
      if (idx != -1) {
        list[idx] = GameSession(
          playedAt: session.playedAt,
          gameType: session.gameType,
          xpEarned: xp,
          score: score,
          durationSeconds: session.durationSeconds,
          mistakes: session.mistakes,
        );
        await _activityService.debugSaveSessions();
        if (!mounted) return;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev: Sessions'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final s = _sessions[index];
            return ListTile(
              title:
                  Text('${s.gameType} • XP ${s.xpEarned} • Score ${s.score}'),
              subtitle: Text(_dateFormat.format(s.playedAt)),
              onTap: () => _editSession(s),
              trailing: IconButton(
                icon:
                    const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(s),
              ),
            );
          },
        ),
      ),
    );
  }
}
