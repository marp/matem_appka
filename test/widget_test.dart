// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matem_appka/main.dart';
import 'package:matem_appka/pages/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // HomePage redirects to /welcome on first launch.
    // In tests we want to stay on the main menu.
    SharedPreferences.setMockInitialValues(<String, Object>{
      'is_first_launch': false,
    });
  });

  testWidgets('Main menu shows core actions and allows navigation',
      (WidgetTester tester) async {
    // HomePage uses a fairly tall Column with spacing; on the default
    // test surface it can overflow. Use a larger virtual screen.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    // Let async init work settle (SharedPreferences + stats load).
    await tester.pumpAndSettle();

    // Main menu buttons.
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Time Trial'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Pass & Play'), findsOneWidget);

    // Quick sanity check that the top-right quick actions exist.
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.info), findsOneWidget);

    // Navigate to Settings using the quick action.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
