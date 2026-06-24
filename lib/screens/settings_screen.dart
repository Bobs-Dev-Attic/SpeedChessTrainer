import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/board_theme.dart';
import '../models/time_control.dart';
import '../state/settings_provider.dart';
import '../theme/app_themes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _Label('Time control'),
          _TimeControlPicker(settings: settings),
          const SizedBox(height: 20),
          const _Label('Appearance'),
          _ThemeModePicker(settings: settings),
          const SizedBox(height: 12),
          _AccentPicker(settings: settings),
          const SizedBox(height: 16),
          const _Label('Board theme'),
          _BoardThemePicker(settings: settings),
          const SizedBox(height: 20),
          const _Label('Gameplay'),
          _ToggleCard(settings: settings),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
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

class _TimeControlPicker extends StatelessWidget {
  const _TimeControlPicker({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final current = settings.timeControl;
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tc in TimeControl.presets)
              ChoiceChip(
                label: Text('${tc.name}  (${tc.label})'),
                selected: current.name == tc.name &&
                    current.baseSeconds == tc.baseSeconds &&
                    current.incrementSeconds == tc.incrementSeconds,
                onSelected: (_) => settings.setTimeControl(tc),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Custom time control'),
            onPressed: () => _customDialog(context, settings),
          ),
        ),
      ],
    );
  }

  void _customDialog(BuildContext context, SettingsProvider settings) {
    double base = settings.timeControl.baseSeconds / 60.0;
    double inc = settings.timeControl.incrementSeconds.toDouble();
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Custom time control'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Base time: ${base.toStringAsFixed(base < 1 ? 2 : 0)} min'),
              Slider(
                value: base,
                min: 0.5,
                max: 30,
                divisions: 59,
                onChanged: (v) => setState(() => base = v),
              ),
              Text('Increment: ${inc.round()} s'),
              Slider(
                value: inc,
                min: 0,
                max: 30,
                divisions: 30,
                onChanged: (v) => setState(() => inc = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final seconds = (base * 60).round();
                settings.setTimeControl(TimeControl(
                  name: 'Custom',
                  baseSeconds: seconds,
                  incrementSeconds: inc.round(),
                ));
                Navigator.of(ctx).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {settings.themeMode},
      onSelectionChanged: (s) => settings.setThemeMode(s.first),
    );
  }
}

class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in AppThemes.accentChoices)
          GestureDetector(
            onTap: () => settings.setAccent(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: settings.accent.value == color.value
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: settings.accent.value == color.value
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _BoardThemePicker extends StatelessWidget {
  const _BoardThemePicker({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BoardTheme.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = BoardTheme.all[i];
          final selected = settings.boardThemeId == t.id;
          return GestureDetector(
            onTap: () => settings.setBoardTheme(t.id),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: ColoredBox(color: t.lightSquare)),
                            Expanded(child: ColoredBox(color: t.darkSquare)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: ColoredBox(color: t.darkSquare)),
                            Expanded(child: ColoredBox(color: t.lightSquare)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  child: Text(
                    t.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Show legal moves'),
            subtitle: const Text('Highlight destinations for a selected piece'),
            value: settings.showLegalMoves,
            onChanged: settings.setShowLegalMoves,
          ),
          SwitchListTile(
            title: const Text('Show coordinates'),
            value: settings.showCoordinates,
            onChanged: settings.setShowCoordinates,
          ),
          SwitchListTile(
            title: const Text('Highlight last move'),
            value: settings.showLastMove,
            onChanged: settings.setShowLastMove,
          ),
          SwitchListTile(
            title: const Text('Enable hints'),
            subtitle: const Text('Allow asking the engine for a suggestion'),
            value: settings.hintsEnabled,
            onChanged: settings.setHintsEnabled,
          ),
          SwitchListTile(
            title: const Text('Auto-queen'),
            subtitle: const Text('Promote pawns to a queen without asking'),
            value: settings.autoQueen,
            onChanged: settings.setAutoQueen,
          ),
        ],
      ),
    );
  }
}
