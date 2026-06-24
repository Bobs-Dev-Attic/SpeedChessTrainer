import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'state/game_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_themes.dart';

void main() {
  // Run everything in one zone so binding init and runApp share it, and any
  // uncaught error is surfaced on screen (Vercel/web only logs the server
  // side, so a client crash would otherwise just show a blank page).
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Show real error text instead of a blank/grey box when a widget throws.
    ErrorWidget.builder = (FlutterErrorDetails details) => Material(
          color: const Color(0xFF3A0A0A),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Speed Chess Trainer error:\n\n'
                '${details.exceptionAsString()}\n\n${details.stack}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        );

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      prefs = null;
    }
    runApp(SpeedChessApp(prefs: prefs));
  }, (error, stack) {
    // ignore: avoid_print
    print('Uncaught zone error: $error\n$stack');
  });
}

class SpeedChessApp extends StatelessWidget {
  const SpeedChessApp({super.key, required this.prefs});

  final SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Speed Chess Trainer',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppThemes.light(settings.accent),
            darkTheme: AppThemes.dark(settings.accent),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
