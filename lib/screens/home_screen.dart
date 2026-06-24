import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/opponent.dart';
import '../state/game_provider.dart';
import '../state/settings_provider.dart';
import 'game_screen.dart';
import 'opponent_select_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final opponent = settings.opponent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Chess Trainer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _Hero(scheme: scheme),
            const SizedBox(height: 16),
            _SectionLabel('Your opponent'),
            _OpponentCard(opponent: opponent, settings: settings),
            const SizedBox(height: 16),
            _SectionLabel('Time control'),
            _TimeControlRow(settings: settings),
            const SizedBox(height: 16),
            _SectionLabel('You play as'),
            _SidePicker(settings: settings),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text('Start Game'),
              onPressed: () => _startGame(context, settings),
            ),
            const SizedBox(height: 24),
            const _TipsCard(),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, SettingsProvider settings) {
    bool humanIsWhite;
    switch (settings.playerSide) {
      case PlayerSide.white:
        humanIsWhite = true;
        break;
      case PlayerSide.black:
        humanIsWhite = false;
        break;
      case PlayerSide.random:
        humanIsWhite = Random().nextBool();
        break;
    }

    context.read<GameProvider>().newGame(
          opponent: settings.opponent,
          personality: settings.activePersonality,
          timeControl: settings.timeControl,
          humanIsWhite: humanIsWhite,
        );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Row(
        children: [
          const Text('♞', style: TextStyle(fontSize: 56, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Train your speed chess',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Spar with configurable bots and legends, ask for hints, '
                  'and rewind every game to learn from it.',
                  style: TextStyle(
                    color: scheme.onPrimary.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _OpponentCard extends StatelessWidget {
  const _OpponentCard({required this.opponent, required this.settings});
  final Opponent opponent;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final p = settings.activePersonality;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OpponentSelectScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: opponent.accent,
                child: Text(
                  opponent.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            opponent.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (settings.customPersonality != null)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Chip(
                              label: Text('custom'),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${opponent.title} · ${p.styleLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeControlRow extends StatelessWidget {
  const _TimeControlRow({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final tc = settings.timeControl;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tc.category} · ${tc.label}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to change time & themes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidePicker extends StatelessWidget {
  const _SidePicker({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PlayerSide>(
      segments: const [
        ButtonSegment(
          value: PlayerSide.white,
          label: Text('White'),
          icon: Text('♔', style: TextStyle(fontSize: 18)),
        ),
        ButtonSegment(
          value: PlayerSide.random,
          label: Text('Random'),
          icon: Icon(Icons.casino_outlined),
        ),
        ButtonSegment(
          value: PlayerSide.black,
          label: Text('Black'),
          icon: Text('♚', style: TextStyle(fontSize: 18)),
        ),
      ],
      selected: {settings.playerSide},
      onSelectionChanged: (s) => settings.setPlayerSide(s.first),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  static const _tips = [
    'Develop fast: get your knights and bishops out before move 10.',
    'In bullet, prioritise safe moves and pre-moves over deep calculation.',
    'Castle early to tuck your king away and connect your rooks.',
    'When low on time, look for checks, captures and threats first.',
    'Use the hint button to learn the engine\'s idea, then try to beat it.',
    'Rewind your losses afterward to find the move that went wrong.',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Speed chess tips',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tip in _tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: TextStyle(color: scheme.primary)),
                  Expanded(
                    child: Text(tip, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
