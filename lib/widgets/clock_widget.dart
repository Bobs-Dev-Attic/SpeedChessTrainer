import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// A single player's countdown clock. [forWhite] selects which side.
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key, required this.forWhite});

  final bool forWhite;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final ms = forWhite ? game.whiteMs : game.blackMs;
    final isActive = !game.isGameOver &&
        game.turn == (forWhite ? ch.Color.WHITE : ch.Color.BLACK);
    final low = ms <= 10000;

    final scheme = Theme.of(context).colorScheme;
    final bg = isActive
        ? (low ? const Color(0xFFB71C1C) : scheme.primary)
        : scheme.surfaceContainerHighest;
    final fg = isActive ? scheme.onPrimary : scheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive && low ? const Color(0xFFB71C1C) : bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.timer : Icons.timer_outlined,
            size: 18,
            color: fg,
          ),
          const SizedBox(width: 8),
          Text(
            _format(ms),
            style: TextStyle(
              color: fg,
              fontSize: 26,
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _format(int ms) {
    if (ms < 0) ms = 0;
    final totalSeconds = ms ~/ 1000;
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    if (m == 0 && totalSeconds < 10) {
      // Show tenths in the final seconds.
      final tenths = (ms % 1000) ~/ 100;
      return '$s.$tenths';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
