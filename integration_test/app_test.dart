import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matem_appka/main.dart';
import 'package:matem_appka/pages/settings_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // HomePage redirects to /welcome on first launch.
    // In integration tests we want to land on the main menu.
    SharedPreferences.setMockInitialValues(<String, Object>{
      'is_first_launch': false,
    });
  });

  testWidgets('App starts and can open Settings', (WidgetTester tester) async {
    // A slightly larger surface helps avoid overflows on smaller defaults.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Smoke-check: main menu visible.
    expect(find.text('Play'), findsOneWidget);

    // Open settings.
    expect(find.byIcon(Icons.settings), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });
}

