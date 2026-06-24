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
# --no-web-resources-cdn bundles CanvasKit with the app instead of fetching it
# from gstatic.com at runtime, so the app works even where that CDN is blocked.
flutter build web --release --no-web-resources-cdn

echo "Build complete → build/web"
