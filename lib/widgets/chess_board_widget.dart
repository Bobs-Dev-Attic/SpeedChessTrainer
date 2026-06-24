import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/board_theme.dart';
import '../state/game_provider.dart';
import '../state/settings_provider.dart';
import '../utils/piece_glyphs.dart';

/// The 2D, top-down chess board. Handles selection, legal-move dots,
/// last-move / hint / check highlighting, coordinates and promotion.
class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  String? _selected;
  Set<String> _targets = const {};

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = settings.boardTheme;

    final files = game.humanIsWhite
        ? const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
        : const ['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a'];
    final ranks = game.humanIsWhite
        ? const [8, 7, 6, 5, 4, 3, 2, 1]
        : const [1, 2, 3, 4, 5, 6, 7, 8];

    final lastMove = settings.showLastMove ? game.lastMoveSquares : null;
    final hint = game.hintSquares;
    final checkSquare = _checkSquare(game);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final squareSize = constraints.maxWidth / 8;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  for (var r = 0; r < 8; r++)
                    Expanded(
                      child: Row(
                        children: [
                          for (var f = 0; f < 8; f++)
                            Expanded(
                              child: _buildSquare(
                                context: context,
                                game: game,
                                settings: settings,
                                theme: theme,
                                square: '${files[f]}${ranks[r]}',
                                isLight: (f + r) % 2 == 0,
                                squareSize: squareSize,
                                showFile: r == 7,
                                showRank: f == 0,
                                fileLabel: files[f],
                                rankLabel: '${ranks[r]}',
                                lastMove: lastMove,
                                hint: hint,
                                checkSquare: checkSquare,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSquare({
    required BuildContext context,
    required GameProvider game,
    required SettingsProvider settings,
    required BoardTheme theme,
    required String square,
    required bool isLight,
    required double squareSize,
    required bool showFile,
    required bool showRank,
    required String fileLabel,
    required String rankLabel,
    required List<String>? lastMove,
    required List<String>? hint,
    required String? checkSquare,
  }) {
    final base = isLight ? theme.lightSquare : theme.darkSquare;
    final labelColor = isLight ? theme.darkSquare : theme.lightSquare;
    final piece = game.pieceAt(square);

    final isSelected = _selected == square;
    final isTarget = _targets.contains(square);
    final isLast = lastMove != null && lastMove.contains(square);
    final isHint = hint != null && hint.contains(square);
    final isCheck = checkSquare == square;

    return GestureDetector(
      onTap: () => _onTap(context, game, settings, square),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: base)),
          if (isLast) Positioned.fill(child: ColoredBox(color: theme.lastMove)),
          if (isSelected)
            Positioned.fill(child: ColoredBox(color: theme.selected)),
          if (isCheck)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xCCFF1744), Color(0x00FF1744)],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
          if (isHint)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.hint, width: 4),
                ),
              ),
            ),
          // Coordinate labels.
          if (settings.showCoordinates && showRank)
            Positioned(
              top: 1,
              left: 2,
              child: Text(
                rankLabel,
                style: TextStyle(
                  fontSize: squareSize * 0.20,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
          if (settings.showCoordinates && showFile)
            Positioned(
              bottom: 0,
              right: 2,
              child: Text(
                fileLabel,
                style: TextStyle(
                  fontSize: squareSize * 0.20,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
          // The piece.
          if (piece != null)
            Center(
              child: Text(
                PieceGlyphs.forType(piece.type),
                style: TextStyle(
                  fontSize: squareSize * 0.78,
                  height: 1.0,
                  color: piece.color == ch.Color.WHITE
                      ? Colors.white
                      : const Color(0xFF1A1A1A),
                  shadows: piece.color == ch.Color.WHITE
                      ? const [
                          Shadow(color: Colors.black54, blurRadius: 1.5),
                        ]
                      : const [
                          Shadow(color: Colors.white24, blurRadius: 1),
                        ],
                ),
              ),
            ),
          // Legal-move indicator.
          if (isTarget && settings.showLegalMoves)
            Center(
              child: piece == null
                  ? Container(
                      width: squareSize * 0.32,
                      height: squareSize * 0.32,
                      decoration: BoxDecoration(
                        color: theme.legalMove,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Container(
                      width: squareSize,
                      height: squareSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.legalMove,
                          width: squareSize * 0.09,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  String? _checkSquare(GameProvider game) {
    if (!game.isAtLive || game.isGameOver || !game.inCheck) return null;
    final color = game.turn;
    for (var rank = 1; rank <= 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final sq = '${String.fromCharCode(97 + file)}$rank';
        final pc = game.pieceAt(sq);
        if (pc != null && pc.type == ch.PieceType.KING && pc.color == color) {
          return sq;
        }
      }
    }
    return null;
  }

  void _onTap(
    BuildContext context,
    GameProvider game,
    SettingsProvider settings,
    String square,
  ) {
    if (!game.isInteractive) return;
    game.clearHint();

    if (_selected == null) {
      _selectIfOwn(game, square);
      return;
    }

    if (square == _selected) {
      setState(() {
        _selected = null;
        _targets = const {};
      });
      return;
    }

    if (_targets.contains(square)) {
      _commitMove(context, game, settings, _selected!, square);
      return;
    }

    // Tapped elsewhere: try to select a new own piece, otherwise clear.
    final piece = game.pieceAt(square);
    final ownColor = game.humanIsWhite ? ch.Color.WHITE : ch.Color.BLACK;
    if (piece != null && piece.color == ownColor) {
      _selectIfOwn(game, square);
    } else {
      setState(() {
        _selected = null;
        _targets = const {};
      });
    }
  }

  void _selectIfOwn(GameProvider game, String square) {
    final piece = game.pieceAt(square);
    final ownColor = game.humanIsWhite ? ch.Color.WHITE : ch.Color.BLACK;
    if (piece == null || piece.color != ownColor) return;
    setState(() {
      _selected = square;
      _targets = game.legalTargetsFrom(square);
    });
  }

  Future<void> _commitMove(
    BuildContext context,
    GameProvider game,
    SettingsProvider settings,
    String from,
    String to,
  ) async {
    String? promotion;
    if (game.isPromotion(from, to)) {
      promotion = settings.autoQueen
          ? 'q'
          : await _askPromotion(context, game.humanIsWhite);
      if (promotion == null) return; // cancelled
    }
    game.makeHumanMove(from, to, promotion: promotion);
    setState(() {
      _selected = null;
      _targets = const {};
    });
  }

  Future<String?> _askPromotion(BuildContext context, bool isWhite) {
    final color = isWhite ? Colors.white : const Color(0xFF1A1A1A);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promote to'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final p in const ['q', 'r', 'b', 'n'])
              InkWell(
                onTap: () => Navigator.of(ctx).pop(p),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    PieceGlyphs.forLetter(p),
                    style: TextStyle(fontSize: 44, color: color, shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 2),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
