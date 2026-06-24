import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speed_chess_trainer/screens/home_screen.dart';
import 'package:speed_chess_trainer/screens/settings_screen.dart';
import 'package:speed_chess_trainer/state/game_provider.dart';
import 'package:speed_chess_trainer/state/settings_provider.dart';
import 'package:speed_chess_trainer/theme/app_themes.dart';

Widget _wrap(Widget child, SettingsProvider settings) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ChangeNotifierProvider(create: (_) => GameProvider()),
    ],
    child: MaterialApp(
      theme: AppThemes.light(settings.accent),
      darkTheme: AppThemes.dark(settings.accent),
      themeMode: settings.themeMode,
      home: child,
    ),
  );
}

void main() {
  testWidgets('HomeScreen builds without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsProvider(prefs);

    await tester.pumpWidget(_wrap(const HomeScreen(), settings));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Speed Chess Trainer'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });

  testWidgets('SettingsScreen builds without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsProvider(prefs);

    await tester.pumpWidget(_wrap(const SettingsScreen(), settings));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
