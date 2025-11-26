import 'package:flutter/material.dart';
import 'package:matem_appka/util/audio_service.dart';

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
          ],
        ),
      ),
    );
  }
}
