import 'package:flutter/material.dart';

import '../utils/piece_glyphs.dart';
import 'piece_view.dart';

/// Shows the pieces a side has captured, plus a +N material advantage badge.
class CapturedPieces extends StatelessWidget {
  const CapturedPieces({
    super.key,
    required this.captured,
    required this.advantage,
    required this.whitePieces,
  });

  /// Piece letters (e.g. ['p','p','n']) this side has captured.
  final List<String> captured;

  /// Material advantage in pawns for this side (only shown when positive).
  final int advantage;

  /// Whether the captured pieces belong to the white army (controls colour).
  final bool whitePieces;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Wrap(
            spacing: 1,
            children: [
              for (final letter in captured)
                PieceView(
                  glyph: PieceGlyphs.forLetter(letter),
                  size: 18,
                  isWhite: whitePieces,
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
