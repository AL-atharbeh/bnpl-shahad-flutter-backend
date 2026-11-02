#!/bin/bash
# Switch Google ML Kit (ID card OCR) on or off.
#
#   tool/toggle_mlkit.sh off   # to run on an Apple Silicon iOS simulator
#   tool/toggle_mlkit.sh on    # to build for a real device or for release
#
# ML Kit's iOS binaries carry no arm64 simulator slice, so CocoaPods removes
# arm64 from simulator builds and Xcode is then left with no valid destination.
# Turning ML Kit off swaps in a stub OCR engine and drops the pod, which lets
# the rest of the app run on the simulator. ID fields are then typed by hand.
set -euo pipefail

cd "$(dirname "$0")/.."

MODE="${1:-}"
SERVICES="lib/core/services"
DEP="google_mlkit_text_recognition"

case "$MODE" in
  on)
    cp "$SERVICES/ocr_engine_mlkit.dart" "$SERVICES/ocr_engine.dart"
    # uncomment the dependency if it is commented out
    sed -i '' -E "s|^([[:space:]]*)#[[:space:]]*($DEP:.*)|\1\2|" pubspec.yaml
    echo "✅ ML Kit ON - real OCR. Build for a device; the simulator will fail."
    ;;
  off)
    cp "$SERVICES/ocr_engine_stub.dart" "$SERVICES/ocr_engine.dart"
    # comment the dependency out if it is active
    sed -i '' -E "s|^([[:space:]]*)($DEP:.*)|\1# \2|" pubspec.yaml
    echo "✅ ML Kit OFF - stub OCR. The simulator will build; ID fields are manual."
    ;;
  *)
    echo "usage: $0 on|off"
    exit 1
    ;;
esac

echo
# Switching the dependency changes the package graph, and a stale
# .dart_tool makes the compiler report missing types in unrelated
# packages, so the build state is cleared first.
echo "→ flutter clean"
flutter clean >/dev/null

echo "→ flutter pub get"
flutter pub get

echo
echo "→ pod install"
( cd ios && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install )

echo
echo "Done. Now run: flutter run"
