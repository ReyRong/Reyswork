#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SleepAidApp"
APP_PATH="$ROOT_DIR/build/$APP_NAME.app"
DESTINATION="/Applications/$APP_NAME.app"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ ! -d "$APP_PATH" ]]; then
  "$ROOT_DIR/scripts/build-app.sh" >/dev/null
fi

if [[ -x "$LSREGISTER" ]]; then
  while IFS= read -r registered_app; do
    [[ -d "$registered_app" ]] || continue
    "$LSREGISTER" -u "$registered_app" >/dev/null 2>&1 || true
  done < <(find "$ROOT_DIR/build" -name "$APP_NAME.app" -o -name "$APP_NAME 2.app" -o -name "$APP_NAME 3.app" 2>/dev/null)

  if [[ -d "$DESTINATION" ]]; then
    "$LSREGISTER" -u "$DESTINATION" >/dev/null 2>&1 || true
  fi
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

if [[ -x "$LSREGISTER" ]]; then
  "$LSREGISTER" -f -R -trusted "$DESTINATION" >/dev/null
fi

open "$DESTINATION"
echo "$DESTINATION"
