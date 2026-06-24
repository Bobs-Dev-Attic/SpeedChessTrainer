import 'package:flutter_test/flutter_test.dart';
import 'package:speed_chess_trainer/models/opponent.dart';
import 'package:speed_chess_trainer/models/time_control.dart';
import 'package:speed_chess_trainer/state/game_provider.dart';

void main() {
  test('untimed game reports no clock', () {
    final g = GameProvider();
    g.newGame(
      opponent: Opponent.levels.first,
      personality: Opponent.levels.first.personality,
      timeControl: TimeControl.defaultControl,
      humanIsWhite: true,
      useClock: false,
    );
    expect(g.useClock, isFalse);
    expect(g.isGameOver, isFalse);
    g.dispose(); // no ticker was started
  });

  test('timed game enables the clock', () {
    final g = GameProvider();
    g.newGame(
      opponent: Opponent.levels.first,
      personality: Opponent.levels.first.personality,
      timeControl: TimeControl.defaultControl,
      humanIsWhite: true,
      useClock: true,
    );
    expect(g.useClock, isTrue);
    g.dispose(); // cancels the ticker
  });
}
