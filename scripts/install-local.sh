#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/build/SleepAidApp.app"
DESTINATION="/Applications/SleepAidApp.app"

if [[ ! -d "$APP_PATH" ]]; then
  "$ROOT_DIR/scripts/build-app.sh"
fi

rm -rf "$DESTINATION"
cp -R "$APP_PATH" "$DESTINATION"
open "$DESTINATION"
echo "$DESTINATION"
