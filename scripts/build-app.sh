#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-release}"
APP_NAME="SleepAidApp"
BUILD_DIR="$ROOT_DIR/build"
DERIVED_DATA_DIR="$BUILD_DIR/XcodeDerivedData"
OUTPUT_APP_DIR="$BUILD_DIR/$APP_NAME.app"

case "$CONFIGURATION" in
  debug) XCODE_CONFIGURATION="Debug" ;;
  release) XCODE_CONFIGURATION="Release" ;;
  Debug|Release) XCODE_CONFIGURATION="$CONFIGURATION" ;;
  *) XCODE_CONFIGURATION="$CONFIGURATION" ;;
esac

XCODE_APP_PATH="$DERIVED_DATA_DIR/Build/Products/$XCODE_CONFIGURATION/$APP_NAME.app"

cd "$ROOT_DIR"

if command -v xattr >/dev/null 2>&1; then
  xattr -cr "$ROOT_DIR/Sources/SleepAidApp/Resources"
fi

xcodebuild \
  -project "$ROOT_DIR/$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration "$XCODE_CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

rm -rf "$OUTPUT_APP_DIR"
mkdir -p "$BUILD_DIR"
ditto --noextattr "$XCODE_APP_PATH" "$OUTPUT_APP_DIR"
rm -rf "$OUTPUT_APP_DIR/Contents/Resources/Metadata.appintents"

if command -v xattr >/dev/null 2>&1; then
  xattr -cr "$OUTPUT_APP_DIR"
  xattr -d com.apple.FinderInfo "$OUTPUT_APP_DIR" 2>/dev/null || true
  xattr -d "com.apple.fileprovider.fpfs#P" "$OUTPUT_APP_DIR" 2>/dev/null || true
fi

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$OUTPUT_APP_DIR" >/dev/null
fi

echo "$OUTPUT_APP_DIR"
