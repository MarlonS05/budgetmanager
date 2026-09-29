#!/usr/bin/env bash
# Patches flutter_local_ai's Android build.gradle for Flutter built-in Kotlin.
# Run after `flutter pub get` until the plugin publishes a fixed version.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PATCH_FILE="$ROOT_DIR/patches/flutter_local_ai_android_build.gradle"
PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"

if [[ ! -f "$PATCH_FILE" ]]; then
  echo "Patch file not found: $PATCH_FILE" >&2
  exit 1
fi

shopt -s nullglob
patched=0
for dir in "$PUB_CACHE"/hosted/pub.dev/flutter_local_ai-*/android; do
  cp "$PATCH_FILE" "$dir/build.gradle"
  echo "Patched $dir/build.gradle"
  patched=1
done

if [[ "$patched" -eq 0 ]]; then
  echo "No flutter_local_ai package found in pub cache. Run 'flutter pub get' first." >&2
  exit 1
fi
