#!/usr/bin/env bash
#
# Builds the Flutter web bundle on Vercel.
#
# Vercel's build image does not ship with Flutter, so we fetch a pinned
# stable SDK into ./.flutter-sdk (cached between builds when possible) and
# then build the release web bundle into build/web (the outputDirectory
# configured in vercel.json).

set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
SDK_DIR="$PWD/.flutter-sdk"

if [ ! -x "$SDK_DIR/bin/flutter" ]; then
  echo "Cloning Flutter ($FLUTTER_VERSION)…"
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$SDK_DIR"
fi

export PATH="$SDK_DIR/bin:$PATH"

flutter --version
flutter config --enable-web --no-analytics
flutter pub get

# Build identifiers so the running app can show exactly which deploy it is.
GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
BUILD_TIME="$(date -u '+%Y-%m-%d %H:%M UTC')"
BUILD_ID="${GIT_SHA}-$(date -u +%s)"

# --no-web-resources-cdn bundles CanvasKit with the app instead of fetching it
#   from gstatic.com at runtime, so the app works even where that CDN is blocked.
# --pwa-strategy=none disables Flutter's (no-op) service worker so our own
#   web/sw.js handles offline caching instead.
flutter build web --release --no-web-resources-cdn --pwa-strategy=none \
  --dart-define=GIT_SHA="$GIT_SHA" \
  --dart-define=BUILD_TIME="$BUILD_TIME"

# Stamp the service worker cache name with this build so a new deploy
# invalidates the old cache (otherwise main.dart.js, which is not content
# hashed, would be served stale forever).
sed -i "s/__BUILD_ID__/${BUILD_ID}/g" build/web/sw.js

echo "Build complete → build/web (build ${GIT_SHA} @ ${BUILD_TIME})"
