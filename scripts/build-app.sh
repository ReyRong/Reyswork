#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-debug}"
APP_NAME="SleepAidApp"
DISPLAY_NAME="白噪音"
BUNDLE_ID="${BUNDLE_ID:-app.white-noise.local}"
VERSION="${VERSION:-0.2.0}"
BUILD_NUMBER="${BUILD_NUMBER:-2}"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"
BUILD_DIR="$ROOT_DIR/build"
STAGING_DIR="${TMPDIR:-/tmp}/$APP_NAME-build-$$"
APP_DIR="$STAGING_DIR/$APP_NAME.app"
OUTPUT_APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
trap 'rm -rf "$STAGING_DIR"' EXIT

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION" --product "$APP_NAME"

EXECUTABLE_PATH="$(swift build -c "$CONFIGURATION" --product "$APP_NAME" --show-bin-path)/$APP_NAME"
RESOURCE_BUNDLE="$(dirname "$EXECUTABLE_PATH")/${APP_NAME}_${APP_NAME}.bundle"

rm -rf "$STAGING_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp -X "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"
if [[ -d "$RESOURCE_BUNDLE" ]]; then
  ditto --noextattr "$RESOURCE_BUNDLE" "$RESOURCES_DIR/$(basename "$RESOURCE_BUNDLE")"
fi
if [[ -f "$ROOT_DIR/Sources/SleepAidApp/Resources/AppIcon.icns" ]]; then
  cp -X "$ROOT_DIR/Sources/SleepAidApp/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>zh_CN</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$BUILD_NUMBER</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <false/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

if command -v xattr >/dev/null 2>&1; then
  xattr -cr "$APP_DIR"
  xattr -d com.apple.FinderInfo "$APP_DIR" 2>/dev/null || true
  xattr -d com.apple.FinderInfo "$RESOURCES_DIR/$(basename "$RESOURCE_BUNDLE")" 2>/dev/null || true
fi
if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign "$CODESIGN_IDENTITY" "$APP_DIR" >/dev/null
fi

rm -rf "$OUTPUT_APP_DIR"
mkdir -p "$BUILD_DIR"
ditto --noextattr "$APP_DIR" "$OUTPUT_APP_DIR"

echo "$OUTPUT_APP_DIR"
