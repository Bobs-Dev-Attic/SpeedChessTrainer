import 'dart:math';

import 'package:chess/chess.dart' as ch;

import '../models/personality.dart';

/// A move scored by the engine.
class _ScoredMove {
  final ch.Move move;
  final double score;
  const _ScoredMove(this.move, this.score);
}

/// A lightweight, dependency-free chess engine.
///
/// It uses a negamax search with alpha-beta pruning over a material +
/// piece-square-table evaluation, then layers a [Personality] on top to bias
/// move *selection* (aggression, risk taking, and human-like carelessness).
///
/// The search is intentionally shallow so it stays snappy on the web and on
/// phones — this is a sparring partner / trainer, not a top engine.
///
/// Moves are returned as normalized `{'from','to','promotion'?}` maps which can
/// be handed straight to `chess.Chess.move(...)`.
class ChessAI {
  final Random _rng;

  ChessAI([Random? rng]) : _rng = rng ?? Random();

  /// Persona used for the "hint" feature — strong and never careless.
  static const Personality _hintPersona = Personality(
    aggression: 0.5,
    riskTolerance: 0.0,
    carelessness: 0.0,
    searchDepth: 3,
    thinkTimeMs: 0,
  );

  // All 64 square names, a1..h8.
  static final List<String> _squares = _buildSquares();

  static List<String> _buildSquares() {
    final out = <String>[];
    for (var rank = 1; rank <= 8; rank++) {
      for (var file = 0; file < 8; file++) {
        out.add('${String.fromCharCode(97 + file)}$rank');
      }
    }
    return out;
  }

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  /// Pick a move for the side to move in [fen], shaped by [personality].
  /// Returns a normalized move map, or null if there are no legal moves.
  Future<Map<String, String>?> selectMove(
    String fen,
    Personality personality,
  ) async {
    final scored = _scoreRootMoves(fen, personality);
    if (scored.isEmpty) return null;
    final chosen = _choose(scored, personality);
    if (personality.thinkTimeMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: personality.thinkTimeMs));
    }
    return _toMap(chosen.move);
  }

  /// The objectively best move the engine can find, used for hints.
  Future<Map<String, String>?> bestMove(String fen, {int depth = 3}) async {
    final root = ch.Chess.fromFEN(fen);
    final moves = List<ch.Move>.from(root.moves({'asObjects': true}));
    if (moves.isEmpty) return null;
    _ScoredMove? best;
    for (final m in moves) {
      final g = ch.Chess.fromFEN(fen);
      g.move(m);
      final v = -_negamax(g, depth - 1, -1e9, 1e9, _hintPersona);
      if (best == null || v > best.score) {
        best = _ScoredMove(m, v);
      }
    }
    return best == null ? null : _toMap(best.move);
  }

  Map<String, String> _toMap(ch.Move m) {
    final map = {'from': m.fromAlgebraic, 'to': m.toAlgebraic};
    if (m.promotion != null) map['promotion'] = m.promotion!.name;
    return map;
  }

  // --------------------------------------------------------------------------
  // Search
  // --------------------------------------------------------------------------

  List<_ScoredMove> _scoreRootMoves(String fen, Personality p) {
    final root = ch.Chess.fromFEN(fen);
    final moves = List<ch.Move>.from(root.moves({'asObjects': true}));
    if (moves.isEmpty) return const [];
    final depth = p.searchDepth.clamp(1, 4);
    final scored = <_ScoredMove>[];
    for (final m in moves) {
      final g = ch.Chess.fromFEN(fen);
      g.move(m);
      final givesCheck = g.in_check;
      double val = -_negamax(g, depth - 1, -1e9, 1e9, p);

      // Personality bias applied to the move itself (from the mover's view).
      double bonus = 0;
      if (m.captured != null) {
        bonus += p.aggression * _materialOfType(m.captured!) * 0.25;
      }
      if (givesCheck) {
        bonus += p.aggression * 45;
      }
      scored.add(_ScoredMove(m, val + bonus));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  double _negamax(ch.Chess g, int depth, double alpha, double beta, Personality p) {
    if (depth <= 0 || g.game_over) {
      return _leafEval(g, p);
    }
    final moves = List<ch.Move>.from(g.moves({'asObjects': true}));
    if (moves.isEmpty) {
      return g.in_check ? -100000.0 : 0.0;
    }
    double best = -1e9;
    for (final m in moves) {
      g.move(m);
      final v = -_negamax(g, depth - 1, -beta, -alpha, p);
      g.undo();
      if (v > best) best = v;
      if (best > alpha) alpha = best;
      if (alpha >= beta) break;
    }
    return best;
  }

  /// Static evaluation from the perspective of the side to move.
  double _leafEval(ch.Chess g, Personality p) {
    if (g.in_checkmate) return -100000.0;
    if (g.in_stalemate ||
        g.in_draw ||
        g.insufficient_material ||
        g.in_threefold_repetition) {
      return 0.0;
    }
    final white = _evaluateWhite(g, p);
    return g.turn == ch.Color.WHITE ? white : -white;
  }

  // --------------------------------------------------------------------------
  // Evaluation (always from White's perspective).
  // --------------------------------------------------------------------------

  double _evaluateWhite(ch.Chess g, Personality p) {
    // Locate kings for tropism (aggression) scoring.
    String? whiteKing;
    String? blackKing;
    for (final sq in _squares) {
      final pc = g.get(sq);
      if (pc == null) continue;
      if (pc.type == ch.PieceType.KING) {
        if (pc.color == ch.Color.WHITE) {
          whiteKing = sq;
        } else {
          blackKing = sq;
        }
      }
    }

    double white = 0;
    double black = 0;
    for (final sq in _squares) {
      final pc = g.get(sq);
      if (pc == null) continue;
      final isWhite = pc.color == ch.Color.WHITE;
      double v = _materialOfType(pc.type) + _pst(pc.type, sq, isWhite);

      // Aggression: reward pieces that crowd the enemy king.
      if (p.aggression > 0 && pc.type != ch.PieceType.KING) {
        final enemyKing = isWhite ? blackKing : whiteKing;
        if (enemyKing != null) {
          final d = _chebyshev(sq, enemyKing);
          v += p.aggression * (7 - d) * _tropismWeight(pc.type);
        }
      }

      if (isWhite) {
        white += v;
      } else {
        black += v;
      }
    }
    return white - black;
  }

  int _chebyshev(String a, String b) {
    final df = (a.codeUnitAt(0) - b.codeUnitAt(0)).abs();
    final dr = (int.parse(a[1]) - int.parse(b[1])).abs();
    return max(df, dr);
  }

  // --------------------------------------------------------------------------
  // Move selection shaped by personality.
  // --------------------------------------------------------------------------

  _ScoredMove _choose(List<_ScoredMove> scored, Personality p) {
    if (scored.length == 1) return scored.first;

    // Careless / human error: occasionally pick a clearly worse move.
    if (_rng.nextDouble() < p.carelessness) {
      final idx = 1 + _rng.nextInt(scored.length - 1);
      return scored[idx];
    }

    // Otherwise pick from a window of near-best moves; wider for risk-takers,
    // which produces livelier, more varied play.
    final topCount = (1 + (p.riskTolerance * 4).round()).clamp(1, scored.length);
    final bestScore = scored.first.score;
    final window = 30 + p.riskTolerance * 90;
    final pool = scored
        .take(topCount)
        .where((s) => bestScore - s.score <= window)
        .toList();
    if (pool.isEmpty) return scored.first;
    return pool[_rng.nextInt(pool.length)];
  }

  // --------------------------------------------------------------------------
  // Tables & helpers
  // --------------------------------------------------------------------------

  double _materialOfType(ch.PieceType t) {
    if (t == ch.PieceType.PAWN) return 100;
    if (t == ch.PieceType.KNIGHT) return 320;
    if (t == ch.PieceType.BISHOP) return 330;
    if (t == ch.PieceType.ROOK) return 500;
    if (t == ch.PieceType.QUEEN) return 900;
    return 20000; // king
  }

  double _tropismWeight(ch.PieceType t) {
    if (t == ch.PieceType.QUEEN) return 4;
    if (t == ch.PieceType.ROOK) return 3;
    if (t == ch.PieceType.BISHOP) return 2;
    if (t == ch.PieceType.KNIGHT) return 2;
    return 1; // pawn
  }

  double _pst(ch.PieceType t, String sq, bool isWhite) {
    final file = sq.codeUnitAt(0) - 97; // a=0
    final rank = int.parse(sq[1]); // 1..8
    // Tables are written rank8-first; white reads top-down, black mirrored.
    final index = isWhite ? (8 - rank) * 8 + file : (rank - 1) * 8 + file;
    final table = _tableFor(t);
    return table[index].toDouble();
  }

  List<int> _tableFor(ch.PieceType t) {
    if (t == ch.PieceType.PAWN) return _pawnTable;
    if (t == ch.PieceType.KNIGHT) return _knightTable;
    if (t == ch.PieceType.BISHOP) return _bishopTable;
    if (t == ch.PieceType.ROOK) return _rookTable;
    if (t == ch.PieceType.QUEEN) return _queenTable;
    return _kingTable;
  }

  static const List<int> _pawnTable = [
    0, 0, 0, 0, 0, 0, 0, 0, //
    50, 50, 50, 50, 50, 50, 50, 50, //
    10, 10, 20, 30, 30, 20, 10, 10, //
    5, 5, 10, 25, 25, 10, 5, 5, //
    0, 0, 0, 20, 20, 0, 0, 0, //
    5, -5, -10, 0, 0, -10, -5, 5, //
    5, 10, 10, -20, -20, 10, 10, 5, //
    0, 0, 0, 0, 0, 0, 0, 0, //
  ];

  static const List<int> _knightTable = [
    -50, -40, -30, -30, -30, -30, -40, -50, //
    -40, -20, 0, 0, 0, 0, -20, -40, //
    -30, 0, 10, 15, 15, 10, 0, -30, //
    -30, 5, 15, 20, 20, 15, 5, -30, //
    -30, 0, 15, 20, 20, 15, 0, -30, //
    -30, 5, 10, 15, 15, 10, 5, -30, //
    -40, -20, 0, 5, 5, 0, -20, -40, //
    -50, -40, -30, -30, -30, -30, -40, -50, //
  ];

  static const List<int> _bishopTable = [
    -20, -10, -10, -10, -10, -10, -10, -20, //
    -10, 0, 0, 0, 0, 0, 0, -10, //
    -10, 0, 5, 10, 10, 5, 0, -10, //
    -10, 5, 5, 10, 10, 5, 5, -10, //
    -10, 0, 10, 10, 10, 10, 0, -10, //
    -10, 10, 10, 10, 10, 10, 10, -10, //
    -10, 5, 0, 0, 0, 0, 5, -10, //
    -20, -10, -10, -10, -10, -10, -10, -20, //
  ];

  static const List<int> _rookTable = [
    0, 0, 0, 0, 0, 0, 0, 0, //
    5, 10, 10, 10, 10, 10, 10, 5, //
    -5, 0, 0, 0, 0, 0, 0, -5, //
    -5, 0, 0, 0, 0, 0, 0, -5, //
    -5, 0, 0, 0, 0, 0, 0, -5, //
    -5, 0, 0, 0, 0, 0, 0, -5, //
    -5, 0, 0, 0, 0, 0, 0, -5, //
    0, 0, 0, 5, 5, 0, 0, 0, //
  ];

  static const List<int> _queenTable = [
    -20, -10, -10, -5, -5, -10, -10, -20, //
    -10, 0, 0, 0, 0, 0, 0, -10, //
    -10, 0, 5, 5, 5, 5, 0, -10, //
    -5, 0, 5, 5, 5, 5, 0, -5, //
    0, 0, 5, 5, 5, 5, 0, -5, //
    -10, 5, 5, 5, 5, 5, 0, -10, //
    -10, 0, 5, 0, 0, 0, 0, -10, //
    -20, -10, -10, -5, -5, -10, -10, -20, //
  ];

  static const List<int> _kingTable = [
    -30, -40, -40, -50, -50, -40, -40, -30, //
    -30, -40, -40, -50, -50, -40, -40, -30, //
    -30, -40, -40, -50, -50, -40, -40, -30, //
    -30, -40, -40, -50, -50, -40, -40, -30, //
    -20, -30, -30, -40, -40, -30, -30, -20, //
    -10, -20, -20, -20, -20, -20, -20, -10, //
    20, 20, 0, 0, 0, 0, 20, 20, //
    20, 30, 10, 0, 0, 10, 30, 20, //
  ];
}
