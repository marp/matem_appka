import 'package:flutter/material.dart';
import 'package:matem_appka/model/game_session.dart';
import 'package:matem_appka/util/activity_service.dart';

class HighScoresPage extends StatefulWidget {
  const HighScoresPage({super.key});

  @override
  State<HighScoresPage> createState() => _HighScoresPageState();
}

class HighScoreGroup {
  final String gameType;
  final int bestScore;
  final int gamesPlayed;
  final DateTime lastPlayed;

  HighScoreGroup({
    required this.gameType,
    required this.bestScore,
    required this.gamesPlayed,
    required this.lastPlayed,
  });
}

class _HighScoresPageState extends State<HighScoresPage> {
  final ActivityService _activityService = ActivityService();

  List<HighScoreGroup> _groups = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Zakładamy, że ActivityService.initialize() został już wywołany przy starcie aplikacji.
      final List<GameSession> sessions = _activityService.sessions;

      // Group sessions by gameType
      final Map<String, List<GameSession>> byType = {};
      for (final s in sessions) {
        final key = s.gameType;
        byType.putIfAbsent(key, () => []).add(s);
      }

      final List<HighScoreGroup> groups = [];
      byType.forEach((gameType, typeSessions) {
        if (typeSessions.isEmpty) return;
        int bestScore = 0;
        int gamesPlayed = typeSessions.length;
        DateTime lastPlayed = typeSessions.first.playedAt;

        for (final s in typeSessions) {
          if (s.score > bestScore) {
            bestScore = s.score;
          }
          if (s.playedAt.isAfter(lastPlayed)) {
            lastPlayed = s.playedAt;
          }
        }

        groups.add(HighScoreGroup(
          gameType: gameType,
          bestScore: bestScore,
          gamesPlayed: gamesPlayed,
          lastPlayed: lastPlayed,
        ));
      });

      // Sort groups by bestScore desc, then lastPlayed desc
      groups.sort((a, b) {
        final scoreCompare = b.bestScore.compareTo(a.bestScore);
        if (scoreCompare != 0) return scoreCompare;
        return b.lastPlayed.compareTo(a.lastPlayed);
      });

      // Keep top 10 groups
      final topGroups = groups.length > 10 ? groups.sublist(0, 10) : groups;

      setState(() {
        _groups = topGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load scores.';
        _isLoading = false;
      });
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
        title: const Text('High Scores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Game Modes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHighScores,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return const Center(
        child: Text('No games recorded yet.'),
      );
    }

    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Mode: ${group.gameType}'),
            subtitle: Text(
              'Best score: ${group.bestScore}\nGames played: ${group.gamesPlayed}',
            ),
            isThreeLine: true,
            trailing: Text(
              '${group.lastPlayed.toLocal()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}
