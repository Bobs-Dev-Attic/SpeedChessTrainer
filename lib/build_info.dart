/// Build identifiers injected at compile time via `--dart-define` (see
/// vercel_build.sh). These change on every deploy so you can tell exactly
/// which build you are looking at — unlike the static pubspec version.
class BuildInfo {
  /// Short git commit the build was produced from (e.g. "a1b2c3d").
  static const String gitSha =
      String.fromEnvironment('GIT_SHA', defaultValue: 'local');

  /// UTC build timestamp (e.g. "2026-06-24 14:05 UTC").
  static const String buildTime =
      String.fromEnvironment('BUILD_TIME', defaultValue: '');

  static String get summary {
    final parts = <String>[];
    parts.add('build $gitSha');
    if (buildTime.isNotEmpty) parts.add(buildTime);
    return parts.join(' · ');
  }
}
