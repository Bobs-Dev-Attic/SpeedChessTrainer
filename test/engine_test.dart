import 'package:chess/chess.dart' as ch;
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_chess_trainer/engine/chess_ai.dart';
import 'package:speed_chess_trainer/models/opponent.dart';
import 'package:speed_chess_trainer/models/personality.dart';
import 'package:speed_chess_trainer/models/time_control.dart';

void main() {
  const persona = Personality(
    aggression: 0.6,
    riskTolerance: 0.4,
    carelessness: 0.0,
    searchDepth: 2,
    thinkTimeMs: 0,
  );

  test('AI returns a legal move from the starting position', () async {
    final ai = ChessAI();
    final game = ch.Chess();
    final move = await ai.selectMove(game.fen, persona);
    expect(move, isNotNull);
    final result = game.move(move!);
    expect(result, isTrue);
  });

  test('bestMove (hint) returns a legal move', () async {
    final ai = ChessAI();
    final game = ch.Chess();
    final move = await ai.bestMove(game.fen);
    expect(move, isNotNull);
  });

  test('every opponent has a sane personality profile', () {
    for (final o in Opponent.all) {
      expect(o.personality.aggression, inInclusiveRange(0, 1));
      expect(o.personality.riskTolerance, inInclusiveRange(0, 1));
      expect(o.personality.carelessness, inInclusiveRange(0, 1));
      expect(o.personality.searchDepth, inInclusiveRange(1, 4));
    }
  });

  test('time control formatting', () {
    const tc = TimeControl(name: 'Blitz', baseSeconds: 180, incrementSeconds: 2);
    expect(tc.label, '3 + 2');
    expect(tc.category, 'Blitz');
  });
}
