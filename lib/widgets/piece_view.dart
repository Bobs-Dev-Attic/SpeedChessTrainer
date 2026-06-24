import 'package:flutter/material.dart';

/// Renders a chess piece glyph as outlined, *monochrome* text.
///
/// Two things make this robust:
///  * `foreground` Paint forces the glyph to be drawn with our paint, so it
///    can never fall back to a coloured emoji font (which previously made the
///    pieces render green/black regardless of the requested colour).
///  * A stroke layer is drawn behind a fill layer, giving every piece a crisp
///    outline so white pieces stay legible on light squares (and vice-versa).
class PieceView extends StatelessWidget {
  const PieceView({
    super.key,
    required this.glyph,
    required this.size,
    required this.isWhite,
  });

  final String glyph;
  final double size;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    final fill = isWhite ? Colors.white : const Color(0xFF1F1F1F);
    final outline =
        isWhite ? const Color(0xFF2B2B2B) : const Color(0xFFEDEDED);
    final strokeWidth = size * 0.06;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            glyph,
            textAlign: TextAlign.center,
            style: _style(
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = outline,
            ),
          ),
          Text(
            glyph,
            textAlign: TextAlign.center,
            style: _style(
              Paint()
                ..style = PaintingStyle.fill
                ..color = fill,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _style(Paint paint) => TextStyle(
        fontSize: size,
        height: 1.0,
        fontFamily: 'NotoChessSymbols',
        foreground: paint,
      );
}
