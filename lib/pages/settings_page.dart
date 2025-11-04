import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isMusicEnabled = true;
  bool isSoundEffectsEnabled = true;

  @override
  void initState() {
    super.initState();
    // TODO: Load saved settings from persistent storage if needed
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
              onChanged: (value) {
                setState(() {
                  isMusicEnabled = value;
                  // TODO: Add logic to enable/disable music
                });
              },
            ),
            SwitchListTile(
              title: const Text('Sound Effects'),
              value: isSoundEffectsEnabled,
              onChanged: (value) {
                setState(() {
                  isSoundEffectsEnabled = value;
                  // TODO: Add logic to enable/disable sound effects
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
