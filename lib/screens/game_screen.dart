import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/captured_pieces.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/clock_widget.dart';
import '../widgets/move_history.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _announced = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();

    // Announce the result once, when the game ends.
    if (game.isGameOver && !_announced) {
      _announced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showResultDialog(context, game);
      });
    }
    if (!game.isGameOver) _announced = false;

    final opponentIsWhite = !game.humanIsWhite;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.opponent.name),
        actions: [
          IconButton(
            tooltip: 'Resign',
            icon: const Icon(Icons.flag_outlined),
            onPressed: game.isGameOver ? null : () => _confirmResign(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _PlayerPanel(
                name: game.opponent.name,
                subtitle: game.aiThinking
                    ? 'Thinking…'
                    : '${game.personality.styleLabel} • ${game.opponent.title}',
                forWhite: opponentIsWhite,
                captured: game.capturedBy(byWhite: opponentIsWhite),
                advantage: -game.materialBalance,
                isOpponent: true,
                thinking: game.aiThinking,
              ),
              const SizedBox(height: 8),
              const ChessBoardWidget(),
              const SizedBox(height: 8),
              _PlayerPanel(
                name: 'You',
                subtitle: 'Make your move',
                forWhite: game.humanIsWhite,
                captured: game.capturedBy(byWhite: game.humanIsWhite),
                advantage: game.materialBalance,
                isOpponent: false,
                thinking: false,
              ),
              const SizedBox(height: 8),
              _Controls(game: game, settings: settings),
              const SizedBox(height: 8),
              const Expanded(child: MoveHistory()),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmResign(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resign game?'),
        content: const Text('Your opponent will be awarded the win.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GameProvider>().resign();
              Navigator.of(ctx).pop();
            },
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, GameProvider game) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Game over'),
        content: Text(game.resultText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Review'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // back to home
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GameProvider>().rematch();
              Navigator.of(ctx).pop();
            },
            child: const Text('Rematch'),
          ),
        ],
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.name,
    required this.subtitle,
    required this.forWhite,
    required this.captured,
    required this.advantage,
    required this.isOpponent,
    required this.thinking,
  });

  final String name;
  final String subtitle;
  final bool forWhite;
  final List<String> captured;
  final int advantage;
  final bool isOpponent;
  final bool thinking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (thinking) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              CapturedPieces(captured: captured, advantage: advantage),
            ],
          ),
        ),
        ClockWidget(forWhite: forWhite),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.game, required this.settings});
  final GameProvider game;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              tooltip: 'Start',
              onPressed: game.canStepBack ? game.goToStart : null,
              icon: const Icon(Icons.first_page),
            ),
            IconButton.filledTonal(
              tooltip: 'Back',
              onPressed: game.canStepBack ? game.stepBack : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              game.livePly == 0
                  ? 'Start'
                  : 'Move ${game.viewPly} / ${game.livePly}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton.filledTonal(
              tooltip: 'Forward',
              onPressed: game.canStepForward ? game.stepForward : null,
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton.filledTonal(
              tooltip: 'Live',
              onPressed: game.canStepForward ? game.goLive : null,
              icon: const Icon(Icons.last_page),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (settings.hintsEnabled)
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: game.hintLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lightbulb_outline),
                  label: const Text('Hint'),
                  onPressed: game.isInteractive && !game.hintLoading
                      ? game.requestHint
                      : null,
                ),
              ),
            if (settings.hintsEnabled) const SizedBox(width: 10),
            Expanded(
              child: game.isGameOver
                  ? FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rematch'),
                      onPressed: game.rematch,
                    )
                  : OutlinedButton.icon(
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Resign'),
                      onPressed: () => _resign(context),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  void _resign(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resign game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GameProvider>().resign();
              Navigator.of(ctx).pop();
            },
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }
}
