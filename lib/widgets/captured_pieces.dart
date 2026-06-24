import 'package:flutter/material.dart';

import '../utils/piece_glyphs.dart';

/// Shows the pieces a side has captured, plus a +N material advantage badge.
class CapturedPieces extends StatelessWidget {
  const CapturedPieces({
    super.key,
    required this.captured,
    required this.advantage,
  });

  /// Piece letters (e.g. ['p','p','n']) this side has captured.
  final List<String> captured;

  /// Material advantage in pawns for this side (only shown when positive).
  final int advantage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Wrap(
            spacing: -4,
            children: [
              for (final letter in captured)
                Text(
                  PieceGlyphs.forLetter(letter),
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'NotoChessSymbols',
                    color: Color(0xFF1A1A1A),
                    shadows: [Shadow(color: Colors.white30, blurRadius: 1)],
                  ),
                ),
            ],
          ),
        ),
        if (advantage > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+$advantage',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
