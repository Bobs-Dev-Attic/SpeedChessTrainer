/// A speed-chess time control: a base time plus an optional per-move increment.
class TimeControl {
  final String name;
  final int baseSeconds;
  final int incrementSeconds;

  const TimeControl({
    required this.name,
    required this.baseSeconds,
    required this.incrementSeconds,
  });

  /// Category label derived from the base time, the way chess servers do it.
  String get category {
    final m = baseSeconds / 60.0;
    if (m < 3) return 'Bullet';
    if (m < 10) return 'Blitz';
    if (m < 30) return 'Rapid';
    return 'Classical';
  }

  String get label {
    final mins = baseSeconds ~/ 60;
    final secs = baseSeconds % 60;
    final base = secs == 0 ? '$mins' : '$mins:${secs.toString().padLeft(2, '0')}';
    return '$base + $incrementSeconds';
  }

  TimeControl copyWith({String? name, int? baseSeconds, int? incrementSeconds}) =>
      TimeControl(
        name: name ?? this.name,
        baseSeconds: baseSeconds ?? this.baseSeconds,
        incrementSeconds: incrementSeconds ?? this.incrementSeconds,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseSeconds': baseSeconds,
        'incrementSeconds': incrementSeconds,
      };

  factory TimeControl.fromJson(Map<String, dynamic> json) => TimeControl(
        name: json['name'] as String,
        baseSeconds: json['baseSeconds'] as int,
        incrementSeconds: json['incrementSeconds'] as int,
      );

  static const List<TimeControl> presets = [
    TimeControl(name: 'Bullet', baseSeconds: 60, incrementSeconds: 0),
    TimeControl(name: 'Bullet +1', baseSeconds: 60, incrementSeconds: 1),
    TimeControl(name: 'Blitz 3', baseSeconds: 180, incrementSeconds: 0),
    TimeControl(name: 'Blitz 3+2', baseSeconds: 180, incrementSeconds: 2),
    TimeControl(name: 'Blitz 5', baseSeconds: 300, incrementSeconds: 0),
    TimeControl(name: 'Blitz 5+3', baseSeconds: 300, incrementSeconds: 3),
    TimeControl(name: 'Rapid 10', baseSeconds: 600, incrementSeconds: 0),
    TimeControl(name: 'Rapid 10+5', baseSeconds: 600, incrementSeconds: 5),
  ];

  static const TimeControl defaultControl =
      TimeControl(name: 'Blitz 3+2', baseSeconds: 180, incrementSeconds: 2);
}
