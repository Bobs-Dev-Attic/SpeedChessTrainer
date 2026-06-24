import 'package:flutter/material.dart';

/// Colour palette for the 2D board: light/dark squares plus highlight tints.
class BoardTheme {
  final String id;
  final String name;
  final Color lightSquare;
  final Color darkSquare;

  /// Tint applied to the squares of the most recent move.
  final Color lastMove;

  /// Tint for the currently selected square.
  final Color selected;

  /// Dot/ring color used to show legal destinations.
  final Color legalMove;

  /// Tint used when highlighting a suggested move (hint).
  final Color hint;

  const BoardTheme({
    required this.id,
    required this.name,
    required this.lightSquare,
    required this.darkSquare,
    required this.lastMove,
    required this.selected,
    required this.legalMove,
    required this.hint,
  });

  static const List<BoardTheme> all = [
    BoardTheme(
      id: 'green',
      name: 'Tournament Green',
      lightSquare: Color(0xFFEEEED2),
      darkSquare: Color(0xFF769656),
      lastMove: Color(0x99F6F669),
      selected: Color(0x9920B2AA),
      legalMove: Color(0x66000000),
      hint: Color(0xAA3D85C6),
    ),
    BoardTheme(
      id: 'wood',
      name: 'Walnut Wood',
      lightSquare: Color(0xFFE8C99B),
      darkSquare: Color(0xFFA66D43),
      lastMove: Color(0x99FFD86B),
      selected: Color(0x99FF8A65),
      legalMove: Color(0x55000000),
      hint: Color(0xAA1565C0),
    ),
    BoardTheme(
      id: 'blue',
      name: 'Ocean Blue',
      lightSquare: Color(0xFFDEE3E6),
      darkSquare: Color(0xFF4B7399),
      lastMove: Color(0x99FFE082),
      selected: Color(0x9926C6DA),
      legalMove: Color(0x55102030),
      hint: Color(0xAA00897B),
    ),
    BoardTheme(
      id: 'slate',
      name: 'Slate Grey',
      lightSquare: Color(0xFFD9D9D9),
      darkSquare: Color(0xFF7A7A7A),
      lastMove: Color(0x99FFEB3B),
      selected: Color(0x9900BCD4),
      legalMove: Color(0x55000000),
      hint: Color(0xAA5E35B1),
    ),
    BoardTheme(
      id: 'midnight',
      name: 'Midnight',
      lightSquare: Color(0xFF6E7A99),
      darkSquare: Color(0xFF2B3245),
      lastMove: Color(0x99FFC107),
      selected: Color(0x9900E5FF),
      legalMove: Color(0x66FFFFFF),
      hint: Color(0xAA64B5F6),
    ),
    BoardTheme(
      id: 'candy',
      name: 'Candy',
      lightSquare: Color(0xFFFFE0EC),
      darkSquare: Color(0xFFE57399),
      lastMove: Color(0x99FFF176),
      selected: Color(0x997E57C2),
      legalMove: Color(0x55000000),
      hint: Color(0xAA42A5F5),
    ),
  ];

  static BoardTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);
}
