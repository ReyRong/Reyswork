#!/usr/bin/env python3
"""从已批准的月牙声纹原稿生成 macOS 多尺寸图标，不构建 App。"""
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "design" / "app-icon" / "concept-v1.png"
ICONSET = ROOT / "build" / "AppIcon.iconset"
OUTPUT = ROOT / "Sources" / "SleepAidApp" / "Resources" / "AppIcon.icns"

SIZES = {
    "icon_16x16.png": 16,
    "icon_16x16@2x.png": 32,
    "icon_32x32.png": 32,
    "icon_32x32@2x.png": 64,
    "icon_128x128.png": 128,
    "icon_128x128@2x.png": 256,
    "icon_256x256.png": 256,
    "icon_256x256@2x.png": 512,
    "icon_512x512.png": 512,
    "icon_512x512@2x.png": 1024,
}


if __name__ == "__main__":
    if not SOURCE.is_file():
        raise FileNotFoundError(SOURCE)
    ICONSET.mkdir(parents=True, exist_ok=True)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    for filename, size in SIZES.items():
        subprocess.run(
            ["sips", "-z", str(size), str(size), str(SOURCE), "--out", str(ICONSET / filename)],
            check=True, stdout=subprocess.DEVNULL,
        )
    # iconutil 在受限执行环境中可能误报 Invalid Iconset，需在正常 macOS 权限下运行。
    subprocess.run(["iconutil", "-c", "icns", str(ICONSET), "-o", str(OUTPUT)], check=True)
    print(OUTPUT)
