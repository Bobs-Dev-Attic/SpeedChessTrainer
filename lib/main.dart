import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'state/game_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(SpeedChessApp(prefs: prefs));
}

class SpeedChessApp extends StatelessWidget {
  const SpeedChessApp({super.key, required this.prefs});

  final SharedPreferences prefs;

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
