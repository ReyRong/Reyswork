#!/usr/bin/env python3
import math
import struct
import subprocess
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
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


def png_chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def write_png(path, size):
    rows = []
    radius = size * 0.22
    center = size / 2
    for y in range(size):
        row = bytearray([0])
        for x in range(size):
            nx = x / max(1, size - 1)
            ny = y / max(1, size - 1)
            corner_dx = max(abs(x - center) - (center - radius), 0)
            corner_dy = max(abs(y - center) - (center - radius), 0)
            rounded_mask = math.hypot(corner_dx, corner_dy) <= radius
            if not rounded_mask:
                row.extend([0, 0, 0, 0])
                continue

            wave = math.sin((nx * 2.8 + ny * 1.4) * math.tau)
            r = int(34 + 38 * ny + 10 * wave)
            g = int(72 + 70 * (1 - ny))
            b = int(96 + 98 * (1 - nx) + 16 * wave)

            moon_dx = x - size * 0.63
            moon_dy = y - size * 0.34
            moon = math.hypot(moon_dx, moon_dy) < size * 0.13
            cut = math.hypot(x - size * 0.69, y - size * 0.30) < size * 0.12
            if moon and not cut:
                r, g, b = 236, 230, 190

            for band in (0.46, 0.56, 0.66):
                distance = abs(ny - (band + 0.025 * math.sin(nx * math.tau * 1.4)))
                if distance < 0.012 and 0.18 < nx < 0.82:
                    r, g, b = min(255, r + 54), min(255, g + 58), min(255, b + 56)

            row.extend([r, g, b, 255])
        rows.append(bytes(row))

    raw = b"".join(rows)
    data = (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
        + png_chunk(b"IDAT", zlib.compress(raw, 9))
        + png_chunk(b"IEND", b"")
    )
    path.write_bytes(data)


if __name__ == "__main__":
    ICONSET.mkdir(parents=True, exist_ok=True)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    for filename, size in SIZES.items():
        write_png(ICONSET / filename, size)
    subprocess.run(["iconutil", "-c", "icns", str(ICONSET), "-o", str(OUTPUT)], check=True)
    print(OUTPUT)
