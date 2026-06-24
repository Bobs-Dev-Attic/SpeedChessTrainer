import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/board_theme.dart';
import '../models/opponent.dart';
import '../models/personality.dart';
import '../models/time_control.dart';

/// Which side the human plays.
enum PlayerSide { white, black, random }

/// App-wide, persisted preferences: theme, board look, time control, opponent
/// and a custom personality override.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _load();
  }

  final SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  Color _accent = const Color(0xFF769656);
  String _boardThemeId = 'green';
  bool _showLegalMoves = true;
  bool _showCoordinates = true;
  bool _showLastMove = true;
  bool _hintsEnabled = true;
  bool _autoQueen = true;

  TimeControl _timeControl = TimeControl.defaultControl;
  String _opponentId = 'level_casual';
  PlayerSide _playerSide = PlayerSide.white;

  /// When non-null, overrides the selected opponent's built-in personality.
  Personality? _customPersonality;

  // ---- getters -------------------------------------------------------------
  ThemeMode get themeMode => _themeMode;
  Color get accent => _accent;
  String get boardThemeId => _boardThemeId;
  BoardTheme get boardTheme => BoardTheme.byId(_boardThemeId);
  bool get showLegalMoves => _showLegalMoves;
  bool get showCoordinates => _showCoordinates;
  bool get showLastMove => _showLastMove;
  bool get hintsEnabled => _hintsEnabled;
  bool get autoQueen => _autoQueen;
  TimeControl get timeControl => _timeControl;
  String get opponentId => _opponentId;
  Opponent get opponent => Opponent.byId(_opponentId);
  PlayerSide get playerSide => _playerSide;
  Personality? get customPersonality => _customPersonality;

  /// The personality actually used in a game (custom override or built-in).
  Personality get activePersonality => _customPersonality ?? opponent.personality;

  // ---- mutations -----------------------------------------------------------
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs?.setString('themeMode', mode.name);
    notifyListeners();
  }

  void setAccent(Color color) {
    _accent = color;
    _prefs?.setInt('accent', color.value);
    notifyListeners();
  }

  void setBoardTheme(String id) {
    _boardThemeId = id;
    _prefs?.setString('boardTheme', id);
    notifyListeners();
  }

  void setShowLegalMoves(bool v) {
    _showLegalMoves = v;
    _prefs?.setBool('showLegalMoves', v);
    notifyListeners();
  }

  void setShowCoordinates(bool v) {
    _showCoordinates = v;
    _prefs?.setBool('showCoordinates', v);
    notifyListeners();
  }

  void setShowLastMove(bool v) {
    _showLastMove = v;
    _prefs?.setBool('showLastMove', v);
    notifyListeners();
  }

  void setHintsEnabled(bool v) {
    _hintsEnabled = v;
    _prefs?.setBool('hintsEnabled', v);
    notifyListeners();
  }

  void setAutoQueen(bool v) {
    _autoQueen = v;
    _prefs?.setBool('autoQueen', v);
    notifyListeners();
  }

  void setTimeControl(TimeControl tc) {
    _timeControl = tc;
    _prefs?.setString('timeControl',
        '${tc.name}|${tc.baseSeconds}|${tc.incrementSeconds}');
    notifyListeners();
  }

  void setOpponent(String id) {
    _opponentId = id;
    // Choosing a new opponent clears any custom personality override.
    _customPersonality = null;
    _prefs?.setString('opponent', id);
    _prefs?.remove('customPersonality');
    notifyListeners();
  }

  void setPlayerSide(PlayerSide side) {
    _playerSide = side;
    _prefs?.setString('playerSide', side.name);
    notifyListeners();
  }

  void setCustomPersonality(Personality? p) {
    _customPersonality = p;
    if (p == null) {
      _prefs?.remove('customPersonality');
    } else {
      final j = p.toJson();
      _prefs?.setString(
        'customPersonality',
        '${j['aggression']}|${j['riskTolerance']}|${j['carelessness']}|'
            '${j['searchDepth']}|${j['thinkTimeMs']}',
      );
    }
    notifyListeners();
  }

  // ---- persistence ---------------------------------------------------------
  void _load() {
    final tm = _prefs?.getString('themeMode');
    if (tm != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == tm,
        orElse: () => ThemeMode.dark,
      );
    }
    _accent = Color(_prefs?.getInt('accent') ?? _accent.value);
    _boardThemeId = _prefs?.getString('boardTheme') ?? _boardThemeId;
    _showLegalMoves = _prefs?.getBool('showLegalMoves') ?? _showLegalMoves;
    _showCoordinates = _prefs?.getBool('showCoordinates') ?? _showCoordinates;
    _showLastMove = _prefs?.getBool('showLastMove') ?? _showLastMove;
    _hintsEnabled = _prefs?.getBool('hintsEnabled') ?? _hintsEnabled;
    _autoQueen = _prefs?.getBool('autoQueen') ?? _autoQueen;
    _opponentId = _prefs?.getString('opponent') ?? _opponentId;

    final tc = _prefs?.getString('timeControl');
    if (tc != null) {
      final parts = tc.split('|');
      if (parts.length == 3) {
        _timeControl = TimeControl(
          name: parts[0],
          baseSeconds: int.tryParse(parts[1]) ?? 180,
          incrementSeconds: int.tryParse(parts[2]) ?? 2,
        );
      }
    }

    final ps = _prefs?.getString('playerSide');
    if (ps != null) {
      _playerSide = PlayerSide.values.firstWhere(
        (s) => s.name == ps,
        orElse: () => PlayerSide.white,
      );
    }

    final cp = _prefs?.getString('customPersonality');
    if (cp != null) {
      final parts = cp.split('|');
      if (parts.length == 5) {
        _customPersonality = Personality(
          aggression: double.tryParse(parts[0]) ?? 0.5,
          riskTolerance: double.tryParse(parts[1]) ?? 0.5,
          carelessness: double.tryParse(parts[2]) ?? 0.1,
          searchDepth: int.tryParse(parts[3]) ?? 2,
          thinkTimeMs: int.tryParse(parts[4]) ?? 500,
        );
      }
    }
  }
}
