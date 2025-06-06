import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matem_appka/model/highscore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoresPage extends StatefulWidget {
  const HighScoresPage({super.key});

  @override
  State<HighScoresPage> createState() => _HighScoresPageState();
}

class _HighScoresPageState extends State<HighScoresPage> {
  List highScores = [];

  @override
  void initState() {
    super.initState();
    getScores();
  }

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
              'Top Scores',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: highScores.length,
                itemBuilder: (context, index) {
                  final highScore = highScores[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(highScore.username),
                      subtitle: Text('Score: ${highScore.score}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    highScores.clear();
                  });
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.remove('highscores');
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Scores'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getScores() async {
    var prefs = await SharedPreferences.getInstance();
    String? source = prefs.getString('highscores');
    var maps = source != null ? jsonDecode(source) : [];
    setState(() {
      highScores = maps.map((e) => HighScore.fromMap(e)).toList();
    });
  }
}
