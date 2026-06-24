import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/opponent.dart';
import '../models/personality.dart';
import '../state/settings_provider.dart';

class OpponentSelectScreen extends StatelessWidget {
  const OpponentSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Opponent')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _Header('Difficulty Levels'),
          for (final o in Opponent.levels)
            _OpponentTile(
              opponent: o,
              selected: settings.opponentId == o.id,
              settings: settings,
            ),
          const SizedBox(height: 16),
          const _Header('Chess Legends'),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              'Personality profiles are estimates of each player\'s historic '
              'style — aggression, risk and how often they err.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          for (final o in Opponent.historic)
            _OpponentTile(
              opponent: o,
              selected: settings.opponentId == o.id,
              settings: settings,
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, top: 4),
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

class _OpponentTile extends StatelessWidget {
  const _OpponentTile({
    required this.opponent,
    required this.selected,
    required this.settings,
  });

  final Opponent opponent;
  final bool selected;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = selected ? settings.activePersonality : opponent.personality;
    final isCustom = selected && settings.customPersonality != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: selected
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => settings.setOpponent(opponent.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: opponent.accent,
                    child: Text(
                      opponent.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opponent.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          opponent.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: scheme.primary),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                opponent.description,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              _Bar(label: 'Aggression', value: p.aggression),
              _Bar(label: 'Risk taking', value: p.riskTolerance),
              _Bar(label: 'Carelessness', value: p.carelessness),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Strength: depth ${p.searchDepth} · '
                  'thinks ~${(p.thinkTimeMs / 1000).toStringAsFixed(1)}s'
                  '${isCustom ? ' · customised' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Customise'),
                      onPressed: () => _customise(context, settings, opponent),
                    ),
                    if (isCustom)
                      TextButton.icon(
                        icon: const Icon(Icons.restart_alt, size: 18),
                        label: const Text('Reset'),
                        onPressed: () => settings.setCustomPersonality(null),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _customise(
    BuildContext context,
    SettingsProvider settings,
    Opponent opponent,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PersonalityEditor(
        initial: settings.activePersonality,
        opponentName: opponent.name,
        onSave: settings.setCustomPersonality,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                minHeight: 7,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${(value * 100).round()}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalityEditor extends StatefulWidget {
  const _PersonalityEditor({
    required this.initial,
    required this.opponentName,
    required this.onSave,
  });

  final Personality initial;
  final String opponentName;
  final ValueChanged<Personality> onSave;

  @override
  State<_PersonalityEditor> createState() => _PersonalityEditorState();
}

class _PersonalityEditorState extends State<_PersonalityEditor> {
  late double _aggression = widget.initial.aggression;
  late double _risk = widget.initial.riskTolerance;
  late double _careless = widget.initial.carelessness;
  late double _depth = widget.initial.searchDepth.toDouble();
  late double _think = widget.initial.thinkTimeMs.toDouble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customise ${widget.opponentName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _slider('Aggression', _aggression, (v) => setState(() => _aggression = v)),
          _slider('Risk taking', _risk, (v) => setState(() => _risk = v)),
          _slider('Carelessness', _careless, (v) => setState(() => _careless = v)),
          _slider(
            'Strength (depth ${_depth.round()})',
            (_depth - 1) / 3,
            (v) => setState(() => _depth = (1 + v * 3).roundToDouble()),
          ),
          _slider(
            'Think time (${(_think / 1000).toStringAsFixed(1)}s)',
            (_think / 2000).clamp(0, 1),
            (v) => setState(() => _think = (v * 2000).roundToDouble()),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              widget.onSave(Personality(
                aggression: _aggression,
                riskTolerance: _risk,
                carelessness: _careless,
                searchDepth: _depth.round(),
                thinkTimeMs: _think.round(),
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Save personality'),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Slider(value: value.clamp(0, 1), onChanged: onChanged),
      ],
    );
  }
}
