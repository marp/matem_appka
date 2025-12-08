import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matem_appka/const/game.dart';
import 'package:matem_appka/model/game_session.dart';
import 'package:matem_appka/services/activity_service.dart';

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

  Future<void> _addSession() async {
    final xpController = TextEditingController(text: '10');
    GameMode selectedMode = GameMode.play;
    int mistakes = 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Now: ${_dateFormat.format(DateTime.now())}'),
              const SizedBox(height: 12),
              DropdownButtonFormField<GameMode>(
                value: selectedMode,
                decoration: const InputDecoration(labelText: 'Game mode'),
                items: GameMode.values
                    .map(
                      (m) => DropdownMenuItem<GameMode>(
                        value: m,
                        child: Text(gameModeNames[m] ?? m.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setStateDialog(() {
                    selectedMode = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'XP earned'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mistakes'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (mistakes > 0) {
                            setStateDialog(() {
                              mistakes--;
                            });
                          }
                        },
                      ),
                      Text(mistakes.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (mistakes < 3) {
                            setStateDialog(() {
                              mistakes++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final xp = int.tryParse(xpController.text) ?? 0;
      final rand = Random();
      final score = rand.nextInt(101); // 0..100

      _activityService.debugMutableSessions.add(
        GameSession(
          playedAt: DateTime.now(),
          gameType: selectedMode.name,
          xpEarned: xp,
          score: score,
          mistakes: mistakes,
        ),
      );
      await _activityService.debugSaveSessions();
      if (!mounted) return;
      setState(() {});
    }
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
    int mistakes = session.mistakes ?? 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mistakes'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (mistakes > 0) {
                            setStateDialog(() {
                              mistakes--;
                            });
                          }
                        },
                      ),
                      Text(mistakes.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (mistakes < 3) {
                            setStateDialog(() {
                              mistakes++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
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
      ),
    );

    if (result == true) {
      final xp = int.tryParse(xpController.text) ?? session.xpEarned;
      final score = int.tryParse(scoreController.text) ?? session.score;

      final list = _activityService.debugMutableSessions;
      final idx = list.indexOf(session);
      if (idx != -1) {
        list[idx] = GameSession(
          id: session.id,
          playedAt: session.playedAt,
          gameType: session.gameType,
          xpEarned: xp,
          score: score,
          durationSeconds: session.durationSeconds,
          mistakes: mistakes,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSession,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final s = _sessions[index];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.videogame_asset, size: 18),
                      const SizedBox(width: 4),
                      Text(s.gameType),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.military_tech, size: 18),
                          const SizedBox(width: 2),
                          Text('XP ${s.xpEarned}'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_border, size: 18),
                          const SizedBox(width: 2),
                          Text('Score ${s.score}'),
                        ],
                      ),
                      if (s.mistakes != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 18),
                            const SizedBox(width: 2),
                            Text('Mistakes ${s.mistakes}'),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dateFormat.format(s.playedAt)),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${s.id}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              isThreeLine: true,
              onTap: () => _editSession(s),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent),
                onPressed: () => _confirmDelete(s),
              ),
            );
          },
        ),
      ),
    );
  }
}
