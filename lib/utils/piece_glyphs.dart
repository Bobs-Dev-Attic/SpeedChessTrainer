import 'package:chess/chess.dart' as ch;

/// Maps chess pieces to Unicode glyphs so the app needs no image assets.
///
/// We use the *filled* (solid) glyph set for every piece and colour them
/// black or white in the widget layer — this gives the cleanest, highest
/// contrast look on both light and dark squares.
class PieceGlyphs {
  static const Map<String, String> _filled = {
    'k': '♚', // ♚
    'q': '♛', // ♛
    'r': '♜', // ♜
    'b': '♝', // ♝
    'n': '♞', // ♞
    'p': '♟', // ♟
  };

  static String forType(ch.PieceType type) {
    return _filled[letterOf(type)] ?? '?';
  }

  static String forLetter(String letter) => _filled[letter.toLowerCase()] ?? '?';

  static String letterOf(ch.PieceType type) {
    if (type == ch.PieceType.PAWN) return 'p';
    if (type == ch.PieceType.KNIGHT) return 'n';
    if (type == ch.PieceType.BISHOP) return 'b';
    if (type == ch.PieceType.ROOK) return 'r';
    if (type == ch.PieceType.QUEEN) return 'q';
    return 'k';
  }
}
