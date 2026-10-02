#!/usr/bin/env python3
"""Pretvara 8-bit RGB/RGBA PNG u neprozirni 24-bit RGB PNG bez alpha kanala."""

from __future__ import annotations

import argparse
import struct
import zlib
from pathlib import Path

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def chunk(kind: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    )


def paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def unfilter(raw: bytes, width: int, height: int, channels: int) -> list[bytearray]:
    stride = width * channels
    rows: list[bytearray] = []
    offset = 0

    for _ in range(height):
        filter_type = raw[offset]
        offset += 1
        current = bytearray(raw[offset : offset + stride])
        offset += stride
        previous = rows[-1] if rows else bytearray(stride)

        for index in range(stride):
            left = current[index - channels] if index >= channels else 0
            up = previous[index]
            upper_left = previous[index - channels] if index >= channels else 0

            if filter_type == 0:
                value = current[index]
            elif filter_type == 1:
                value = (current[index] + left) & 0xFF
            elif filter_type == 2:
                value = (current[index] + up) & 0xFF
            elif filter_type == 3:
                value = (current[index] + ((left + up) // 2)) & 0xFF
            elif filter_type == 4:
                value = (current[index] + paeth(left, up, upper_left)) & 0xFF
            else:
                raise ValueError(f"Nepodržani PNG filter: {filter_type}")

            current[index] = value

        rows.append(current)

    return rows


def normalize_png(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if not data.startswith(PNG_SIGNATURE):
        raise ValueError(f"{path}: nije PNG")

    offset = len(PNG_SIGNATURE)
    ihdr = None
    idat_parts: list[bytes] = []

    while offset < len(data):
        length = struct.unpack(">I", data[offset : offset + 4])[0]
        kind = data[offset + 4 : offset + 8]
        payload = data[offset + 8 : offset + 8 + length]
        offset += 12 + length

        if kind == b"IHDR":
            ihdr = payload
        elif kind == b"IDAT":
            idat_parts.append(payload)
        elif kind == b"IEND":
            break

    if ihdr is None:
        raise ValueError(f"{path}: nedostaje IHDR")

    width, height, bit_depth, color_type, compression, filtering, interlace = struct.unpack(
        ">IIBBBBB", ihdr
    )
    if bit_depth != 8 or compression != 0 or filtering != 0 or interlace != 0:
        raise ValueError(f"{path}: nepodržana PNG konfiguracija")
    if color_type not in (2, 6):
        raise ValueError(f"{path}: podržani su samo RGB/RGBA PNG-ovi")

    channels = 3 if color_type == 2 else 4
    raw = zlib.decompress(b"".join(idat_parts))
    rows = unfilter(raw, width, height, channels)

    output_rows = bytearray()
    for row in rows:
        output_rows.append(0)
        if channels == 3:
            output_rows.extend(row)
            continue
        for index in range(0, len(row), 4):
            alpha = row[index + 3]
            if alpha != 255:
                raise ValueError(
                    f"{path}: screenshot sadrži prozirne piksele (alpha={alpha})"
                )
            output_rows.extend(row[index : index + 3])

    output = bytearray(PNG_SIGNATURE)
    output.extend(
        chunk(
            b"IHDR",
            struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0),
        )
    )
    output.extend(chunk(b"IDAT", zlib.compress(bytes(output_rows), 9)))
    output.extend(chunk(b"IEND", b""))
    path.write_bytes(output)
    return width, height


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+")
    args = parser.parse_args()

    for pattern in args.paths:
        matches = sorted(Path().glob(pattern))
        if not matches:
            raise SystemExit(f"Nema PNG datoteka za uzorak: {pattern}")
        for path in matches:
            width, height = normalize_png(path)
            print(f"{path}: {width}x{height} RGB bez alpha kanala")


if __name__ == "__main__":
    main()
