import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matem_appka/main.dart';
import 'package:matem_appka/pages/settings_page.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _setTestSurfaceSize(WidgetTester tester) async {
    // Big enough to avoid overflows / tiny default constraints.
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    // Some widgets depend on MediaQuery pixel ratio.
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> _launchApp(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  Future<void> _openSettings(WidgetTester tester) async {
    final settingsButton = find.byIcon(Icons.settings);

    // Prefer user-like interaction. If the icon is not found, fail with a clear expectation.
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();
  }

  void _expectMainMenu() {
    // Keep this assertion minimal to reduce localization coupling.
    // If your UI is localized and this becomes flaky, switch to a Key-based finder.
    expect(find.text('Play'), findsOneWidget);
  }

  void _expectSettingsScreen() {
    expect(find.byType(SettingsPage), findsOneWidget);

    // Optional “anchor” for extra certainty. If the app is localized, consider replacing
    // this with a Key on the Settings AppBar/title.
    expect(find.textContaining('Settings'), findsWidgets);
  }

  setUpAll(() {
    // Ensure the app does not redirect to /welcome (first launch flow) during tests.
    SharedPreferences.setMockInitialValues(<String, Object>{
      'is_first_launch': false,
    });

    // Keep the binding referenced to prevent tree-shaking complaints in some setups.
    // ignore: unnecessary_statements
    binding;
  });

  testWidgets('opens Settings from main menu', (WidgetTester tester) async {
    await _setTestSurfaceSize(tester);

    await _launchApp(tester);
    _expectMainMenu();

    await _openSettings(tester);
    _expectSettingsScreen();
  });
}
