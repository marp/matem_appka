import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String appTitle = '';
  String appVersion = '';

  Future<void> _loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    setState(() {
      appVersion = 'Version: $version (Build $buildNumber)';
      appTitle = appName;
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
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
            Text(
              appTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              appVersion,
              style: TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Developed by: ',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'Marp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                const url = 'https://github.com/marp';
                if (!await launchUrl(
                    Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
                  throw Exception('Could not launch $url');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/github-mark.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Source Code on GitHub',
                    style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Music by ',
                  style: TextStyle(fontSize: 14),
                ),
                InkWell(
                  onTap: () async {
                    const url = 'https://pixabay.com/users/roshan_cariappa-29316619/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=117375';
                    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: const Text(
                    'Roshan Cariappa',
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Sounds by ',
                  style: TextStyle(fontSize: 14),
                ),
                InkWell(
                  onTap: () async {
                    const url = 'https://pixabay.com/users/tuomas_data-40753689/';
                    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: const Text(
                    'Tuomas_Data',
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
