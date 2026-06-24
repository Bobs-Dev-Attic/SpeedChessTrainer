/// Defines how an AI opponent "thinks" and behaves at the board.
///
/// All factors except [searchDepth] and [thinkTimeMs] are normalized 0..1.
class Personality {
  /// How much the engine values attacking, captures and pressure on the
  /// enemy king. Higher = more aggressive, sacrificial, forward-pushing play.
  final double aggression;

  /// Willingness to enter sharp / speculative lines even when the engine's
  /// raw evaluation is not the very best. Higher = more gambit-like.
  final double riskTolerance;

  /// Probability of deviating from the best move into a clearly worse one.
  /// Models human error / "careless" play. 0 = always plays its best.
  final double carelessness;

  /// Search depth in plies (1..4). Bigger = stronger but slower.
  final int searchDepth;

  /// Roughly how long the engine "thinks" before moving, in milliseconds.
  /// Used both to pace blitz feel and to bound search time.
  final int thinkTimeMs;

  const Personality({
    required this.aggression,
    required this.riskTolerance,
    required this.carelessness,
    required this.searchDepth,
    required this.thinkTimeMs,
  });

  Personality copyWith({
    double? aggression,
    double? riskTolerance,
    double? carelessness,
    int? searchDepth,
    int? thinkTimeMs,
  }) {
    return Personality(
      aggression: aggression ?? this.aggression,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      carelessness: carelessness ?? this.carelessness,
      searchDepth: searchDepth ?? this.searchDepth,
      thinkTimeMs: thinkTimeMs ?? this.thinkTimeMs,
    );
  }

  /// A short human-readable label describing the dominant trait.
  String get styleLabel {
    if (carelessness > 0.4) return 'Careless';
    if (aggression > 0.75) return 'Aggressive';
    if (aggression < 0.35) return 'Conservative';
    if (riskTolerance > 0.65) return 'Risky';
    return 'Balanced';
  }

  Map<String, dynamic> toJson() => {
        'aggression': aggression,
        'riskTolerance': riskTolerance,
        'carelessness': carelessness,
        'searchDepth': searchDepth,
        'thinkTimeMs': thinkTimeMs,
      };

  factory Personality.fromJson(Map<String, dynamic> json) => Personality(
        aggression: (json['aggression'] as num).toDouble(),
        riskTolerance: (json['riskTolerance'] as num).toDouble(),
        carelessness: (json['carelessness'] as num).toDouble(),
        searchDepth: json['searchDepth'] as int,
        thinkTimeMs: json['thinkTimeMs'] as int,
      );
}
