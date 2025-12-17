import 'package:flutter/material.dart';
import 'package:matem_appka/model/game_session.dart';
import 'package:matem_appka/services/activity_service.dart';

class HighScoresPage extends StatefulWidget {
  const HighScoresPage({super.key});

  @override
  State<HighScoresPage> createState() => _HighScoresPageState();
}

class _HighScoresPageState extends State<HighScoresPage> {
  final ActivityService _activityService = ActivityService();

  // Top sessions per tab
  List<GameSession> _playSessions = [];
  List<GameSession> _timeTrialSessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  String _modeTabForGameType(String gameType) {
    final lower = gameType.toLowerCase();
    // Heuristic: anything containing 'time' goes to Time Trial, rest to Play
    if (lower.contains('time')) {
      return 'timeTrial';
    }
    return 'play';
  }

  int _scoreForSession(GameSession session) => session.score;

  Future<void> _loadHighScores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Zakładamy, że ActivityService.initialize() został już wywołany przy starcie aplikacji.
      final List<GameSession> sessions = _activityService.sessions;

      final List<GameSession> playSessions = [];
      final List<GameSession> timeTrialSessions = [];

      for (final s in sessions) {
        final tab = _modeTabForGameType(s.gameType);
        if (tab == 'timeTrial') {
          timeTrialSessions.add(s);
        } else {
          playSessions.add(s);
        }
      }

      // Sort each list by score desc, then playedAt desc
      int compareSessions(GameSession a, GameSession b) {
        final scoreCompare = _scoreForSession(b).compareTo(_scoreForSession(a));
        if (scoreCompare != 0) return scoreCompare;
        return b.playedAt.compareTo(a.playedAt);
      }

      playSessions.sort(compareSessions);
      timeTrialSessions.sort(compareSessions);

      // Keep top 10 sessions per tab
      final topPlay =
          playSessions.length > 10 ? playSessions.sublist(0, 10) : playSessions;
      final topTime = timeTrialSessions.length > 10
          ? timeTrialSessions.sublist(0, 10)
          : timeTrialSessions;

      setState(() {
        _playSessions = topPlay;
        _timeTrialSessions = topTime;
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('High Scores'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Play'),
              Tab(text: 'Time Trial'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              context: context,
              title: 'Top 10 Play Scores',
              sessions: _playSessions,
              emptyMessage: 'No Play scores yet.',
            ),
            _buildTabContent(
              context: context,
              title: 'Top 10 Time Trial Scores',
              sessions: _timeTrialSessions,
              emptyMessage: 'No Time Trial scores yet.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required String title,
    required List<GameSession> sessions,
    required String emptyMessage,
  }) {
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

    if (sessions.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final dateTime = session.playedAt.toLocal();
                final twoDigits = (int n) => n.toString().padLeft(2, '0');
                final formattedDate =
                    '${twoDigits(dateTime.day)}.${twoDigits(dateTime.month)}.${dateTime.year} ${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Score: ${session.score}'),
                    trailing: Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
