import 'package:flutter/material.dart';

class DevIndexPage extends StatelessWidget {
  const DevIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
          children: [
          ListTile(
            title: const Text('Dev sessions page'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
                Navigator.of(context).pushNamed('/dev/sessions');
              },
            ),
          const Divider(),
          ListTile(
            title: const Text('Dev reminders page'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
                Navigator.of(context).pushNamed('/dev/reminders');
              },
            ),
          const Divider(),
            // Developer shortcut to onboarding / welcome screen
          ListTile(
            title: const Text('Show welcome screen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
                Navigator.of(context).pushNamed('/welcome');
              },
            ),
          ],
      ),
    );
  }
}