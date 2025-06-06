import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
@override
void initState() {
  super.initState();
  _loadAppInfo();
}
  String appVersion = '';

  Future<void> _loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    setState(() {
      appVersion = 'Version: $version (Build $buildNumber)';
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/logo.png'), // Ensure you have a logo image in assets
            ),
            const Text(
              'Matem Appka',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              appVersion,
              style: TextStyle(fontSize: 16),
            ),
            Row( mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Text(
                'Developed by: ',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Marcin Przybył',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

