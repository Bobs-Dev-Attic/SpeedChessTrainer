import 'dart:async';

import 'package:chess/chess.dart' as ch;
import 'package:flutter/foundation.dart';

import '../engine/chess_ai.dart';
import '../models/opponent.dart';
import '../models/personality.dart';
import '../models/time_control.dart';

enum GameStatus { playing, checkmate, stalemate, draw, timeout, resigned }

/// Owns a single game: the board, both clocks, the full move history with
/// rewind support, and the AI opponent.
class GameProvider extends ChangeNotifier {
  GameProvider({ChessAI? ai}) : _ai = ai ?? ChessAI();

  final ChessAI _ai;

  ch.Chess _game = ch.Chess();
  ch.Chess _viewGame = ch.Chess();

  final List<String> _fens = [];
  final List<String> _sans = [];

  /// [from, to] square pairs for each played half-move (for highlighting).
  final List<List<String>> _moveSquares = [];

  int _viewPly = 0; // index into _fens currently shown

  late Opponent _opponent;
  late Personality _personality;
  late TimeControl _timeControl;
  bool _humanIsWhite = true;

  int _whiteMs = 0;
  int _blackMs = 0;
  Timer? _ticker;

  /// Bumped on every new game so stale async AI results can be discarded.
  int _gameId = 0;

  bool _aiThinking = false;
  bool _hintLoading = false;
  Map<String, String>? _hintMove; // squares to highlight for a hint
  GameStatus _status = GameStatus.playing;
  String _resultText = '';

  // ---- getters -------------------------------------------------------------
  Opponent get opponent => _opponent;
  Personality get personality => _personality;
  TimeControl get timeControl => _timeControl;
  bool get humanIsWhite => _humanIsWhite;
  int get whiteMs => _whiteMs;
  int get blackMs => _blackMs;
  bool get aiThinking => _aiThinking;
  bool get hintLoading => _hintLoading;
  GameStatus get status => _status;
  String get resultText => _resultText;
  bool get isGameOver => _status != GameStatus.playing;

  List<String> get sans => List.unmodifiable(_sans);
  int get viewPly => _viewPly;
  int get livePly => _fens.length - 1;
  bool get isAtLive => _viewPly == livePly;
  bool get canStepBack => _viewPly > 0;
  bool get canStepForward => _viewPly < livePly;

  /// True when the human may interact with the board right now.
  bool get isInteractive =>
      !isGameOver &&
      isAtLive &&
      !_aiThinking &&
      _game.turn == (_humanIsWhite ? ch.Color.WHITE : ch.Color.BLACK);

  ch.Color get turn => _game.turn;
  bool get inCheck => _game.in_check;

  /// Squares to highlight as the most recent move (from/to), or null.
  List<String>? get lastMoveSquares {
    if (_viewPly == 0) return null;
    return _moveSquares[_viewPly - 1];
  }

  List<String>? get hintSquares => _hintMove == null
      ? null
      : [_hintMove!['from']!, _hintMove!['to']!];

  /// The piece on [square] in the currently viewed position.
  ch.Piece? pieceAt(String square) => _viewGame.get(square);

  // ---- lifecycle -----------------------------------------------------------
  void newGame({
    required Opponent opponent,
    required Personality personality,
    required TimeControl timeControl,
    required bool humanIsWhite,
  }) {
    _ticker?.cancel();
    _gameId++;
    _opponent = opponent;
    _personality = personality;
    _timeControl = timeControl;
    _humanIsWhite = humanIsWhite;

    _game = ch.Chess();
    _fens
      ..clear()
      ..add(_game.fen);
    _sans.clear();
    _moveSquares.clear();
    _viewPly = 0;
    _syncViewGame();

    _whiteMs = timeControl.baseSeconds * 1000;
    _blackMs = timeControl.baseSeconds * 1000;
    _aiThinking = false;
    _hintMove = null;
    _status = GameStatus.playing;
    _resultText = '';

    _startTicker();
    notifyListeners();

    // If the AI is White it moves first.
    _maybeTriggerAi();
  }

  /// Replay the same matchup (opponent, personality, time, side).
  void rematch() {
    newGame(
      opponent: _opponent,
      personality: _personality,
      timeControl: _timeControl,
      humanIsWhite: _humanIsWhite,
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), _onTick);
  }

  void _onTick(Timer _) {
    if (isGameOver) return;
    if (_game.turn == ch.Color.WHITE) {
      _whiteMs -= 100;
      if (_whiteMs <= 0) {
        _whiteMs = 0;
        _endByTimeout(whiteFlagged: true);
        return;
      }
    } else {
      _blackMs -= 100;
      if (_blackMs <= 0) {
        _blackMs = 0;
        _endByTimeout(whiteFlagged: false);
        return;
      }
    }
    notifyListeners();
  }

  // ---- interaction ---------------------------------------------------------

  /// Legal destination squares from [square] for the side to move.
  Set<String> legalTargetsFrom(String square) {
    if (!isInteractive) return const {};
    final moves = _game.moves({'verbose': true});
    final out = <String>{};
    for (final m in moves) {
      if (m['from'] == square) out.add(m['to'].toString());
    }
    return out;
  }

  /// Whether a move from->to is a pawn promotion (needs a piece choice).
  /// The verbose flags string contains 'p' for a promotion.
  bool isPromotion(String from, String to) {
    final moves = _game.moves({'verbose': true});
    for (final m in moves) {
      if (m['from'] == from &&
          m['to'] == to &&
          (m['flags']?.toString().contains('p') ?? false)) {
        return true;
      }
    }
    return false;
  }

  /// Apply a human move. [promotion] is one of q/r/b/n when promoting.
  bool makeHumanMove(String from, String to, {String? promotion}) {
    if (!isInteractive) return false;
    final move = {'from': from, 'to': to};
    if (promotion != null) move['promotion'] = promotion;
    final applied = _applyMove(move, addedToColor: _game.turn);
    if (applied) _maybeTriggerAi();
    return applied;
  }

  bool _applyMove(Map<String, String> move, {required ch.Color addedToColor}) {
    _hintMove = null;
    final wasAtLive = isAtLive;
    final ok = _game.move(move);
    if (ok == false) return false;

    // Increment for the side that just moved.
    final incMs = _timeControl.incrementSeconds * 1000;
    if (addedToColor == ch.Color.WHITE) {
      _whiteMs += incMs;
    } else {
      _blackMs += incMs;
    }

    _fens.add(_game.fen);
    final history = _game.getHistory();
    _sans.add(history.isEmpty ? '' : history.last.toString());
    _moveSquares.add([move['from']!, move['to']!]);

    if (wasAtLive) {
      _viewPly = livePly;
      _syncViewGame();
    }

    _evaluateStatus();
    notifyListeners();
    return true;
  }

  Future<void> _maybeTriggerAi() async {
    if (isGameOver) return;
    final aiColor = _humanIsWhite ? ch.Color.BLACK : ch.Color.WHITE;
    if (_game.turn != aiColor) return;
    if (_aiThinking) return;

    _aiThinking = true;
    notifyListeners();

    final fen = _game.fen;
    final myGameId = _gameId;
    final move = await _ai.selectMove(fen, _personality);

    // Guard against a new game / state change during the async gap.
    if (myGameId != _gameId || isGameOver || _game.fen != fen) {
      if (myGameId == _gameId) _aiThinking = false;
      return;
    }
    _aiThinking = false;
    if (move != null) {
      _applyMove(move, addedToColor: aiColor);
    } else {
      _evaluateStatus();
      notifyListeners();
    }
  }

  // ---- hints ---------------------------------------------------------------
  Future<void> requestHint() async {
    if (!isInteractive || _hintLoading) return;
    _hintLoading = true;
    final fen = _game.fen;
    final myGameId = _gameId;
    notifyListeners();
    final move = await _ai.bestMove(fen);
    // Discard if the position moved on while we were thinking.
    if (myGameId != _gameId || _game.fen != fen) {
      _hintLoading = false;
      return;
    }
    _hintLoading = false;
    _hintMove = move;
    notifyListeners();
  }

  void clearHint() {
    if (_hintMove == null) return;
    _hintMove = null;
    notifyListeners();
  }

  // ---- history / rewind ----------------------------------------------------
  void goToPly(int ply) {
    final clamped = ply.clamp(0, livePly);
    if (clamped == _viewPly) return;
    _viewPly = clamped;
    _hintMove = null;
    _syncViewGame();
    notifyListeners();
  }

  void stepBack() => goToPly(_viewPly - 1);
  void stepForward() => goToPly(_viewPly + 1);
  void goToStart() => goToPly(0);
  void goLive() => goToPly(livePly);

  void _syncViewGame() {
    _viewGame = ch.Chess.fromFEN(_fens[_viewPly]);
  }

  // ---- end states ----------------------------------------------------------
  void resign() {
    if (isGameOver) return;
    _ticker?.cancel();
    _status = GameStatus.resigned;
    final winner = _humanIsWhite ? 'Black' : 'White';
    _resultText = '$winner wins — you resigned';
    notifyListeners();
  }

  void _endByTimeout({required bool whiteFlagged}) {
    _ticker?.cancel();
    _status = GameStatus.timeout;
    final winner = whiteFlagged ? 'Black' : 'White';
    _resultText = '$winner wins on time';
    notifyListeners();
  }

  void _evaluateStatus() {
    if (_game.in_checkmate) {
      _ticker?.cancel();
      _status = GameStatus.checkmate;
      // The side NOT to move delivered mate.
      final winner = _game.turn == ch.Color.WHITE ? 'Black' : 'White';
      _resultText = 'Checkmate — $winner wins';
    } else if (_game.in_stalemate) {
      _ticker?.cancel();
      _status = GameStatus.stalemate;
      _resultText = 'Draw — stalemate';
    } else if (_game.in_threefold_repetition) {
      _ticker?.cancel();
      _status = GameStatus.draw;
      _resultText = 'Draw — threefold repetition';
    } else if (_game.insufficient_material) {
      _ticker?.cancel();
      _status = GameStatus.draw;
      _resultText = 'Draw — insufficient material';
    } else if (_game.in_draw) {
      _ticker?.cancel();
      _status = GameStatus.draw;
      _resultText = 'Draw — 50-move rule';
    }
  }

  /// Captured-piece tally for [byWhite]: letters of pieces that side has won.
  List<String> capturedBy({required bool byWhite}) {
    // Compare current board against the standard starting complement.
    const start = {'p': 8, 'n': 2, 'b': 2, 'r': 2, 'q': 1};
    final remaining = <String, int>{};
    for (final sq in _allSquares()) {
      final pc = _viewGame.get(sq);
      if (pc == null || pc.type == ch.PieceType.KING) continue;
      final isWhitePiece = pc.color == ch.Color.WHITE;
      // We count the opponent's surviving pieces to derive what `byWhite` took.
      if (isWhitePiece == byWhite) continue;
      final letter = _letterOf(pc.type);
      remaining[letter] = (remaining[letter] ?? 0) + 1;
    }
    final out = <String>[];
    start.forEach((letter, count) {
      final lost = count - (remaining[letter] ?? 0);
      for (var i = 0; i < lost; i++) {
        out.add(letter);
      }
    });
    return out;
  }

  /// Net material score (positive = the human is ahead) in pawns.
  int get materialBalance {
    const values = {'p': 1, 'n': 3, 'b': 3, 'r': 5, 'q': 9};
    int white = 0;
    int black = 0;
    for (final sq in _allSquares()) {
      final pc = _viewGame.get(sq);
      if (pc == null || pc.type == ch.PieceType.KING) continue;
      final v = values[_letterOf(pc.type)] ?? 0;
      if (pc.color == ch.Color.WHITE) {
        white += v;
      } else {
        black += v;
      }
    }
    final humanAhead = _humanIsWhite ? white - black : black - white;
    return humanAhead;
  }

  String _letterOf(ch.PieceType t) {
    if (t == ch.PieceType.PAWN) return 'p';
    if (t == ch.PieceType.KNIGHT) return 'n';
    if (t == ch.PieceType.BISHOP) return 'b';
    if (t == ch.PieceType.ROOK) return 'r';
    if (t == ch.PieceType.QUEEN) return 'q';
    return 'k';
  }

  Iterable<String> _allSquares() sync* {
    for (var rank = 1; rank <= 8; rank++) {
      for (var file = 0; file < 8; file++) {
        yield '${String.fromCharCode(97 + file)}$rank';
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
