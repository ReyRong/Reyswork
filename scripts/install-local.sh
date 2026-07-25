#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SleepAidApp"
APP_PATH="$ROOT_DIR/build/$APP_NAME.app"
DESTINATION="/Applications/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  "$ROOT_DIR/scripts/build-app.sh" >/dev/null
fi

rm -rf "$DESTINATION"
ditto --noextattr "$APP_PATH" "$DESTINATION"

if command -v xattr >/dev/null 2>&1; then
  xattr -cr "$DESTINATION"
  xattr -d com.apple.FinderInfo "$DESTINATION" 2>/dev/null || true
  xattr -d "com.apple.fileprovider.fpfs#P" "$DESTINATION" 2>/dev/null || true
fi

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$DESTINATION" >/dev/null
fi

open "$DESTINATION"
echo "$DESTINATION"
