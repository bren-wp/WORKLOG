#!/usr/bin/env python3
"""Generira WORKLOG raster brand assete bez vanjskih Python ovisnosti."""

from __future__ import annotations

import json
import math
import struct
import zlib
from pathlib import Path

DARK = (6, 17, 31)
BLUE = (59, 130, 246)
CYAN = (19, 200, 255)
MID = (22, 119, 255)
VIOLET = (90, 114, 255)

ROOT = Path(__file__).resolve().parents[1]


def _png_chunk(kind: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    )


def write_png(path: Path, width: int, height: int, pixels: bytearray, alpha: bool = False) -> None:
    channels = 4 if alpha else 3
    rows = bytearray()
    stride = width * channels
    for y in range(height):
        rows.append(0)
        start = y * stride
        rows.extend(pixels[start : start + stride])

    color_type = 6 if alpha else 2
    payload = bytearray(b"\x89PNG\r\n\x1a\n")
    payload.extend(
        _png_chunk(
            b"IHDR",
            struct.pack(">IIBBBBB", width, height, 8, color_type, 0, 0, 0),
        )
    )
    payload.extend(_png_chunk(b"IDAT", zlib.compress(bytes(rows), 9)))
    payload.extend(_png_chunk(b"IEND", b""))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(payload)


def _bezier(p0, p1, p2, p3, steps=16):
    result = []
    for index in range(1, steps + 1):
        t = index / steps
        inv = 1.0 - t
        x = (
            inv**3 * p0[0]
            + 3 * inv * inv * t * p1[0]
            + 3 * inv * t * t * p2[0]
            + t**3 * p3[0]
        )
        y = (
            inv**3 * p0[1]
            + 3 * inv * inv * t * p1[1]
            + 3 * inv * t * t * p2[1]
            + t**3 * p3[1]
        )
        result.append((x, y))
    return result


def worklog_mark_points():
    points = [
        (82.0, 150.0),
        (176.0, 150.0),
        (256.0, 318.0),
        (336.0, 150.0),
        (430.0, 150.0),
        (319.0, 365.0),
    ]
    points.extend(_bezier((319, 365), (294, 412), (261, 418), (234, 368)))
    points.append((195.0, 294.0))
    points.append((157.0, 368.0))
    points.extend(_bezier((157, 368), (133, 414), (103, 403), (82, 363)))
    points.extend([(16.0, 232.0), (82.0, 150.0)])
    return points


def _gradient(x: float, y: float, size: int):
    sx, sy = 0.18 * size, 0.25 * size
    ex, ey = 0.82 * size, 0.76 * size
    dx, dy = ex - sx, ey - sy
    length = dx * dx + dy * dy
    t = ((x - sx) * dx + (y - sy) * dy) / length
    t = max(0.0, min(1.0, t))
    if t <= 0.52:
        local = t / 0.52
        a, b = CYAN, MID
    else:
        local = (t - 0.52) / 0.48
        a, b = MID, VIOLET
    return tuple(round(a[i] + (b[i] - a[i]) * local) for i in range(3))


def _scaled_mark(size: int, scale: float = 1.0, offset_y: float = 0.0):
    source = worklog_mark_points()
    factor = size / 512.0 * scale
    cx = 256.0
    cy = 256.0
    return [
        (
            (x - cx) * factor + size / 2,
            (y - cy) * factor + size / 2 + offset_y * size,
        )
        for x, y in source
    ]


def _fill_polygon_rgb(pixels: bytearray, size: int, points):
    for y in range(size):
        scan_y = y + 0.5
        intersections = []
        for index, first in enumerate(points):
            second = points[(index + 1) % len(points)]
            x1, y1 = first
            x2, y2 = second
            if (y1 <= scan_y < y2) or (y2 <= scan_y < y1):
                x = x1 + (scan_y - y1) * (x2 - x1) / (y2 - y1)
                intersections.append(x)
        intersections.sort()
        for left, right in zip(intersections[0::2], intersections[1::2]):
            start = max(0, math.ceil(left))
            end = min(size, math.floor(right) + 1)
            for x in range(start, end):
                r, g, b = _gradient(x, y, size)
                pos = (y * size + x) * 3
                pixels[pos : pos + 3] = bytes((r, g, b))


def _fill_polygon_rgba(pixels: bytearray, size: int, points):
    for y in range(size):
        scan_y = y + 0.5
        intersections = []
        for index, first in enumerate(points):
            second = points[(index + 1) % len(points)]
            x1, y1 = first
            x2, y2 = second
            if (y1 <= scan_y < y2) or (y2 <= scan_y < y1):
                x = x1 + (scan_y - y1) * (x2 - x1) / (y2 - y1)
                intersections.append(x)
        intersections.sort()
        for left, right in zip(intersections[0::2], intersections[1::2]):
            start = max(0, math.ceil(left))
            end = min(size, math.floor(right) + 1)
            for x in range(start, end):
                r, g, b = _gradient(x, y, size)
                pos = (y * size + x) * 4
                pixels[pos : pos + 4] = bytes((r, g, b, 255))


def _inside_rounded_rect(x: float, y: float, size: int, inset: float, radius: float) -> bool:
    left = inset
    top = inset
    right = size - inset
    bottom = size - inset
    if left + radius <= x <= right - radius and top <= y <= bottom:
        return True
    if top + radius <= y <= bottom - radius and left <= x <= right:
        return True
    centers = (
        (left + radius, top + radius),
        (right - radius, top + radius),
        (left + radius, bottom - radius),
        (right - radius, bottom - radius),
    )
    return any((x - cx) ** 2 + (y - cy) ** 2 <= radius**2 for cx, cy in centers)


def render_icon(size: int) -> bytearray:
    pixels = bytearray(DARK * (size * size))
    inset = max(4, round(size * 0.014))
    border = max(3, round(size * 0.018))
    radius = size * 0.22

    for y in range(size):
        for x in range(size):
            outer = _inside_rounded_rect(x + 0.5, y + 0.5, size, inset, radius)
            inner = _inside_rounded_rect(
                x + 0.5,
                y + 0.5,
                size,
                inset + border,
                max(1.0, radius - border),
            )
            if outer and not inner:
                pos = (y * size + x) * 3
                pixels[pos : pos + 3] = bytes((32, 132, 255))

    _fill_polygon_rgb(pixels, size, _scaled_mark(size, scale=1.02, offset_y=0.015))
    return pixels


def render_mark(size: int, scale: float = 0.78) -> bytearray:
    pixels = bytearray(size * size * 4)
    _fill_polygon_rgba(pixels, size, _scaled_mark(size, scale=scale))
    return pixels


def render_feature_graphic(width: int = 1024, height: int = 500) -> bytearray:
    pixels = bytearray(width * height * 3)
    for y in range(height):
        for x in range(width):
            t = (x / max(width - 1, 1)) * 0.7 + (y / max(height - 1, 1)) * 0.3
            r = round(DARK[0] + 5 * t)
            g = round(DARK[1] + 17 * t)
            b = round(DARK[2] + 36 * t)
            pos = (y * width + x) * 3
            pixels[pos : pos + 3] = bytes((r, g, b))

    mark_size = 430
    mark = render_mark(mark_size, scale=0.92)
    x0 = (width - mark_size) // 2
    y0 = (height - mark_size) // 2
    for y in range(mark_size):
        for x in range(mark_size):
            src = (y * mark_size + x) * 4
            alpha = mark[src + 3]
            if alpha == 0:
                continue
            dst = ((y0 + y) * width + (x0 + x)) * 3
            pixels[dst : dst + 3] = mark[src : src + 3]
    return pixels


def generate_store_assets() -> None:
    generated = ROOT / "assets" / "brand" / "generated"
    write_png(generated / "worklog-app-icon-1024.png", 1024, 1024, render_icon(1024))
    write_png(
        generated / "worklog-splash-mark-512.png",
        512,
        512,
        render_mark(512),
        alpha=True,
    )

    android_store = ROOT / "store" / "android" / "assets"
    write_png(android_store / "worklog-app-icon-512.png", 512, 512, render_icon(512))
    write_png(
        android_store / "worklog-feature-graphic-1024x500.png",
        1024,
        500,
        render_feature_graphic(),
    )

    ios_store = ROOT / "store" / "ios" / "assets"
    write_png(ios_store / "worklog-app-store-icon-1024.png", 1024, 1024, render_icon(1024))


def generate_android() -> None:
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in sizes.items():
        write_png(res / folder / "ic_launcher.png", size, size, render_icon(size))

    drawable = res / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    vector = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:aapt="http://schemas.android.com/aapt"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path android:pathData="M82,150H176L256,318L336,150H430L319,365C294,412 261,418 234,368L195,294L157,368C133,414 103,403 82,363L16,232L82,150Z">
        <aapt:attr name="android:fillColor">
            <gradient
                android:type="linear"
                android:startX="90"
                android:startY="130"
                android:endX="420"
                android:endY="390"
                android:startColor="#13C8FF"
                android:centerColor="#1677FF"
                android:endColor="#5A72FF" />
        </aapt:attr>
    </path>
</vector>
"""
    (drawable / "worklog_foreground.xml").write_text(vector, encoding="utf-8")
    monochrome = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="512"
    android:viewportHeight="512">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M82,150H176L256,318L336,150H430L319,365C294,412 261,418 234,368L195,294L157,368C133,414 103,403 82,363L16,232L82,150Z" />
</vector>
"""
    (drawable / "worklog_monochrome.xml").write_text(monochrome, encoding="utf-8")

    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    adaptive = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/worklog_icon_background" />
    <foreground android:drawable="@drawable/worklog_foreground" />
    <monochrome android:drawable="@drawable/worklog_monochrome" />
</adaptive-icon>
"""
    (anydpi / "ic_launcher.xml").write_text(adaptive, encoding="utf-8")
    (anydpi / "ic_launcher_round.xml").write_text(adaptive, encoding="utf-8")

    values = res / "values"
    values.mkdir(parents=True, exist_ok=True)
    colors_path = values / "colors.xml"
    colors = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="worklog_icon_background">#06111F</color>
    <color name="worklog_splash_background">#06111F</color>
</resources>
"""
    colors_path.write_text(colors, encoding="utf-8")


def generate_ios() -> None:
    root = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    root.mkdir(parents=True, exist_ok=True)

    specifications = [
        ("20x20", "2x", 40),
        ("20x20", "3x", 60),
        ("29x29", "1x", 29),
        ("29x29", "2x", 58),
        ("29x29", "3x", 87),
        ("40x40", "1x", 40),
        ("40x40", "2x", 80),
        ("40x40", "3x", 120),
        ("60x60", "2x", 120),
        ("60x60", "3x", 180),
        ("76x76", "1x", 76),
        ("76x76", "2x", 152),
        ("83.5x83.5", "2x", 167),
        ("1024x1024", "1x", 1024),
    ]
    images = []
    for logical, scale, pixels in specifications:
        filename = f"worklog-{logical.replace('.', '_')}-{scale}.png"
        write_png(root / filename, pixels, pixels, render_icon(pixels))
        idiom = "ios-marketing" if pixels == 1024 else ("ipad" if logical in {"76x76", "83.5x83.5"} else "iphone")
        images.append(
            {
                "idiom": idiom,
                "size": logical,
                "scale": scale,
                "filename": filename,
            }
        )
    (root / "Contents.json").write_text(
        json.dumps({"images": images, "info": {"version": 1, "author": "WORKLOG"}}, indent=2)
        + "\n",
        encoding="utf-8",
    )

    launch = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    launch.mkdir(parents=True, exist_ok=True)
    launch_images = []
    for scale, pixels in (("1x", 320), ("2x", 640), ("3x", 960)):
        filename = f"worklog-launch-{scale}.png"
        write_png(launch / filename, pixels, pixels, render_mark(pixels), alpha=True)
        launch_images.append(
            {
                "idiom": "universal",
                "scale": scale,
                "filename": filename,
            }
        )
    (launch / "Contents.json").write_text(
        json.dumps(
            {"images": launch_images, "info": {"version": 1, "author": "WORKLOG"}},
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


def main() -> None:
    generate_store_assets()
    if (ROOT / "android").exists():
        generate_android()
    if (ROOT / "ios").exists():
        generate_ios()
    print("WORKLOG brand asseti su generirani.")


if __name__ == "__main__":
    main()
