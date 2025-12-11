import 'package:flutter/material.dart';
import 'package:matem_appka/pages/about_page.dart';
import 'package:matem_appka/pages/activity_page.dart';
import 'package:matem_appka/pages/dev_index_page.dart';
import 'package:matem_appka/pages/dev_reminders_page.dart';
import 'package:matem_appka/pages/dev_sessions_page.dart';
import 'package:matem_appka/pages/game_page.dart';
import 'package:matem_appka/pages/highscores_page.dart';
import 'package:matem_appka/pages/home_page.dart';
import 'package:matem_appka/pages/settings_page.dart';
import 'package:matem_appka/pages/welcome_page.dart';
import 'package:matem_appka/services/audio_service.dart';
import 'package:matem_appka/services/streak_service.dart';
import 'package:matem_appka/services/xp_service.dart';
import 'package:matem_appka/services/activity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService().initialize();
  await AudioService().playBackgroundMusic();
  await StreakService().initialize();
  await XpService().initialize();
  await ActivityService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matem Appka',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/welcome': (context) => const WelcomePage(),
        '/game': (context) => const GamePage(),
        '/about': (context) => const AboutPage(),
        '/highScores': (context) => const HighScoresPage(),
        '/settings': (context) => const SettingsPage(),
        '/activity': (context) => const ActivityPage(),
        '/dev/index': (context) => const DevIndexPage(),
        '/dev/sessions': (context) => const DevSessionsPage(),
        '/dev/reminders': (context) => const DevRemindersPage(),
      },
    );
  }
}
