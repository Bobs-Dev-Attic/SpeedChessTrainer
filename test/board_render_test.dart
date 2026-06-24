import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speed_chess_trainer/models/opponent.dart';
import 'package:speed_chess_trainer/models/time_control.dart';
import 'package:speed_chess_trainer/state/game_provider.dart';
import 'package:speed_chess_trainer/state/settings_provider.dart';
import 'package:speed_chess_trainer/theme/app_themes.dart';
import 'package:speed_chess_trainer/widgets/chess_board_widget.dart';

void main() {
  testWidgets('white pieces render white, black pieces dark, monochrome font',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsProvider(prefs);
    final game = GameProvider();
    game.newGame(
      opponent: Opponent.levels.first,
      personality: Opponent.levels.first.personality,
      timeControl: TimeControl.defaultControl,
      humanIsWhite: true,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ChangeNotifierProvider<GameProvider>.value(value: game),
        ],
        child: MaterialApp(
          theme: AppThemes.dark(settings.accent),
          home: const Scaffold(body: ChessBoardWidget()),
        ),
      ),
    );
    await tester.pump();

    // All 16 pawns use the filled glyph ♟ (U+265F), distinguished by colour.
    final pawns = tester.widgetList<Text>(find.text('♟')).toList();
    expect(pawns.length, 16);

    final white = pawns.where((t) => t.style?.color == Colors.white).length;
    final black =
        pawns.where((t) => t.style?.color == const Color(0xFF1A1A1A)).length;
    expect(white, 8, reason: 'white player should have 8 white pawns');
    expect(black, 8, reason: 'opponent should have 8 dark pawns');

    for (final t in pawns) {
      expect(t.style?.fontFamily, 'NotoChessSymbols',
          reason: 'pieces must use the bundled monochrome chess font');
    }

    game.resign(); // stop the clock timer before the test ends
    await tester.pump();
  });
}
