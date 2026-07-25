#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SleepAidApp"
DISPLAY_NAME="白噪音"
VERSION="${VERSION:-0.3.0}"
BUILD_DIR="$ROOT_DIR/build"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$DISPLAY_NAME-$VERSION.dmg"
STAGING_DIR="${TMPDIR:-/tmp}/$APP_NAME-dmg-$$"

trap 'rm -rf "$STAGING_DIR"' EXIT

cd "$ROOT_DIR"
CONFIGURATION="${CONFIGURATION:-release}" "$ROOT_DIR/scripts/build-app.sh" >/dev/null

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

ditto --noextattr "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
if command -v xattr >/dev/null 2>&1; then
  xattr -cr "$STAGING_DIR/$APP_NAME.app"
  xattr -d com.apple.FinderInfo "$STAGING_DIR/$APP_NAME.app" 2>/dev/null || true
  xattr -d "com.apple.fileprovider.fpfs#P" "$STAGING_DIR/$APP_NAME.app" 2>/dev/null || true
fi
if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$STAGING_DIR/$APP_NAME.app" >/dev/null
fi
ln -s /Applications "$STAGING_DIR/Applications"

rm -f "$DMG_PATH"
hdiutil create \
  -volname "$DISPLAY_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

echo "$DMG_PATH"
