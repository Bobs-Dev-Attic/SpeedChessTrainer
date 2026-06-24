import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';

/// Scrollable, tappable move list. Tapping a move rewinds the board to that
/// position; the current view ply is highlighted.
class MoveHistory extends StatelessWidget {
  const MoveHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final sans = game.sans;
    final scheme = Theme.of(context).colorScheme;

    final rows = <Widget>[];
    for (var i = 0; i < sans.length; i += 2) {
      final moveNo = (i ~/ 2) + 1;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  '$moveNo.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _MoveChip(
                san: sans[i],
                ply: i + 1,
                isCurrent: game.viewPly == i + 1,
              ),
              const SizedBox(width: 6),
              if (i + 1 < sans.length)
                _MoveChip(
                  san: sans[i + 1],
                  ply: i + 2,
                  isCurrent: game.viewPly == i + 2,
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: sans.isEmpty
          ? Center(
              child: Text(
                'No moves yet — make your first move!',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: rows,
            ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    required this.san,
    required this.ply,
    required this.isCurrent,
  });

  final String san;
  final int ply;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => context.read<GameProvider>().goToPly(ply),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isCurrent ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          san,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
