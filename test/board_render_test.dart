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
import 'package:speed_chess_trainer/widgets/piece_view.dart';

void main() {
  testWidgets('white pawns render as white pieces, black as dark',
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

    // All 16 pawns render via PieceView using the filled glyph ♟ (U+265F).
    final pawns = tester
        .widgetList<PieceView>(find.byType(PieceView))
        .where((p) => p.glyph == '♟')
        .toList();
    expect(pawns.length, 16);

    final white = pawns.where((p) => p.isWhite).length;
    final black = pawns.where((p) => !p.isWhite).length;
    expect(white, 8, reason: 'white player should have 8 white pawns');
    expect(black, 8, reason: 'opponent should have 8 dark pawns');

    game.resign(); // stop the clock timer before the test ends
    await tester.pump();
  });
}
