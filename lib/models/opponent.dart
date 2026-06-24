import 'package:flutter/material.dart';

import 'personality.dart';

/// An AI opponent: either a generic difficulty level or a historic player
/// with a personality estimated from their known playing style.
class Opponent {
  final String id;
  final String name;

  /// e.g. "World Champion 1960–61" or "Difficulty Level".
  final String title;
  final String description;
  final Personality personality;

  /// Accent color used on cards / avatars.
  final Color accent;

  /// True for the curated historic-player roster.
  final bool isHistoric;

  const Opponent({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.personality,
    required this.accent,
    this.isHistoric = false,
  });

  /// Up to two initials used as a simple avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Opponent copyWith({Personality? personality, String? name}) => Opponent(
        id: id,
        name: name ?? this.name,
        title: title,
        description: description,
        personality: personality ?? this.personality,
        accent: accent,
        isHistoric: isHistoric,
      );

  // ---------------------------------------------------------------------------
  // Generic difficulty levels.
  // ---------------------------------------------------------------------------
  static const List<Opponent> levels = [
    Opponent(
      id: 'level_beginner',
      name: 'Beginner Bot',
      title: 'Difficulty Level',
      description:
          'Just learning the ropes. Plays shallow and blunders often — '
          'perfect for warming up and trying new ideas.',
      accent: Color(0xFF4CAF50),
      personality: Personality(
        aggression: 0.5,
        riskTolerance: 0.5,
        carelessness: 0.45,
        searchDepth: 1,
        thinkTimeMs: 350,
      ),
    ),
    Opponent(
      id: 'level_casual',
      name: 'Casual Bot',
      title: 'Difficulty Level',
      description:
          'A relaxed club-night opponent. Sees one move ahead reliably and '
          'only occasionally lets something hang.',
      accent: Color(0xFF66BB6A),
      personality: Personality(
        aggression: 0.55,
        riskTolerance: 0.45,
        carelessness: 0.25,
        searchDepth: 2,
        thinkTimeMs: 450,
      ),
    ),
    Opponent(
      id: 'level_club',
      name: 'Club Player',
      title: 'Difficulty Level',
      description:
          'Solid tactics and few free gifts. A real test for the improving '
          'speed-chess player.',
      accent: Color(0xFFFFB300),
      personality: Personality(
        aggression: 0.6,
        riskTolerance: 0.45,
        carelessness: 0.12,
        searchDepth: 2,
        thinkTimeMs: 600,
      ),
    ),
    Opponent(
      id: 'level_expert',
      name: 'Expert',
      title: 'Difficulty Level',
      description:
          'Calculates deeper and rarely blunders. Punishes loose play and '
          'sloppy clock management.',
      accent: Color(0xFFFB8C00),
      personality: Personality(
        aggression: 0.65,
        riskTolerance: 0.45,
        carelessness: 0.05,
        searchDepth: 3,
        thinkTimeMs: 750,
      ),
    ),
    Opponent(
      id: 'level_master',
      name: 'Master',
      title: 'Difficulty Level',
      description:
          'The toughest generic setting. Deep, precise and almost never '
          'gives material away for free.',
      accent: Color(0xFFE53935),
      personality: Personality(
        aggression: 0.7,
        riskTolerance: 0.5,
        carelessness: 0.02,
        searchDepth: 3,
        thinkTimeMs: 900,
      ),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Historic players with estimated personality profiles.
  // ---------------------------------------------------------------------------
  static const List<Opponent> historic = [
    Opponent(
      id: 'morphy',
      name: 'Paul Morphy',
      title: 'Romantic Era · 1837–1884',
      description:
          'The pride of New Orleans. Lightning development and relentless '
          'attacks — sacrifices flow as soon as you fall behind in development.',
      accent: Color(0xFF8E24AA),
      isHistoric: true,
      personality: Personality(
        aggression: 0.9,
        riskTolerance: 0.8,
        carelessness: 0.12,
        searchDepth: 2,
        thinkTimeMs: 500,
      ),
    ),
    Opponent(
      id: 'tal',
      name: 'Mikhail Tal',
      title: 'World Champion 1960–61',
      description:
          '"The Magician from Riga." Wildly aggressive and famous for '
          'intuitive sacrifices that drag you into a forest of complications.',
      accent: Color(0xFFD81B60),
      isHistoric: true,
      personality: Personality(
        aggression: 0.97,
        riskTolerance: 0.95,
        carelessness: 0.18,
        searchDepth: 2,
        thinkTimeMs: 550,
      ),
    ),
    Opponent(
      id: 'capablanca',
      name: 'José Raúl Capablanca',
      title: 'World Champion 1921–27',
      description:
          'The Cuban endgame machine. Crystal-clear, almost error-free '
          'positional play that simplifies and squeezes you dry.',
      accent: Color(0xFF00897B),
      isHistoric: true,
      personality: Personality(
        aggression: 0.4,
        riskTolerance: 0.2,
        carelessness: 0.03,
        searchDepth: 3,
        thinkTimeMs: 800,
      ),
    ),
    Opponent(
      id: 'petrosian',
      name: 'Tigran Petrosian',
      title: 'World Champion 1963–69',
      description:
          '"Iron Tigran." Prophylactic and ultra-solid — he removes your '
          'counterplay before you even see it, then grinds.',
      accent: Color(0xFF546E7A),
      isHistoric: true,
      personality: Personality(
        aggression: 0.2,
        riskTolerance: 0.12,
        carelessness: 0.03,
        searchDepth: 3,
        thinkTimeMs: 850,
      ),
    ),
    Opponent(
      id: 'fischer',
      name: 'Bobby Fischer',
      title: 'World Champion 1972–75',
      description:
          'Brutally precise and universal. Aggressive when given the chance '
          'and merciless about converting the smallest edge.',
      accent: Color(0xFF1E88E5),
      isHistoric: true,
      personality: Personality(
        aggression: 0.7,
        riskTolerance: 0.5,
        carelessness: 0.02,
        searchDepth: 3,
        thinkTimeMs: 900,
      ),
    ),
    Opponent(
      id: 'kasparov',
      name: 'Garry Kasparov',
      title: 'World Champion 1985–2000',
      description:
          'Dynamic, attacking and superbly prepared. Seizes the initiative '
          'and overwhelms with deep, energetic calculation.',
      accent: Color(0xFFC62828),
      isHistoric: true,
      personality: Personality(
        aggression: 0.85,
        riskTolerance: 0.7,
        carelessness: 0.03,
        searchDepth: 3,
        thinkTimeMs: 900,
      ),
    ),
    Opponent(
      id: 'karpov',
      name: 'Anatoly Karpov',
      title: 'World Champion 1975–85',
      description:
          'The python. Quiet, positional and patient — he restricts your '
          'pieces and tightens the grip until you suffocate.',
      accent: Color(0xFF3949AB),
      isHistoric: true,
      personality: Personality(
        aggression: 0.35,
        riskTolerance: 0.2,
        carelessness: 0.03,
        searchDepth: 3,
        thinkTimeMs: 850,
      ),
    ),
    Opponent(
      id: 'carlsen',
      name: 'Magnus Carlsen',
      title: 'World Champion 2013–23',
      description:
          'The universal grinder. Comfortable in any structure, squeezes '
          'tiny edges forever and pounces the moment you slip.',
      accent: Color(0xFF00ACC1),
      isHistoric: true,
      personality: Personality(
        aggression: 0.55,
        riskTolerance: 0.4,
        carelessness: 0.02,
        searchDepth: 3,
        thinkTimeMs: 900,
      ),
    ),
    Opponent(
      id: 'nakamura',
      name: 'Hikaru Nakamura',
      title: 'Speed-chess Legend',
      description:
          'One of the fastest hands in the game. Sharp, tactical and '
          'practically built for bullet and blitz time scrambles.',
      accent: Color(0xFFF4511E),
      isHistoric: true,
      personality: Personality(
        aggression: 0.75,
        riskTolerance: 0.6,
        carelessness: 0.07,
        searchDepth: 2,
        thinkTimeMs: 300,
      ),
    ),
    Opponent(
      id: 'lasker',
      name: 'Emanuel Lasker',
      title: 'World Champion 1894–1921',
      description:
          'The pragmatic fighter. Plays the opponent as much as the board '
          'and thrives in messy, double-edged battles.',
      accent: Color(0xFF6D4C41),
      isHistoric: true,
      personality: Personality(
        aggression: 0.6,
        riskTolerance: 0.55,
        carelessness: 0.05,
        searchDepth: 3,
        thinkTimeMs: 800,
      ),
    ),
    Opponent(
      id: 'careless_carl',
      name: 'Careless Carl',
      title: 'Just For Fun',
      description:
          'Means well, sees little. Carl loves to attack but leaves pieces '
          'hanging all over the board — great for confidence and practice.',
      accent: Color(0xFF9E9D24),
      isHistoric: true,
      personality: Personality(
        aggression: 0.6,
        riskTolerance: 0.6,
        carelessness: 0.6,
        searchDepth: 1,
        thinkTimeMs: 250,
      ),
    ),
  ];

  static List<Opponent> get all => [...levels, ...historic];

  static Opponent byId(String id) =>
      all.firstWhere((o) => o.id == id, orElse: () => levels[1]);
}
