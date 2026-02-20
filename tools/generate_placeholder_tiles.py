"""Generate a placeholder tileset PNG for Italy Valley.

Creates a 112x16 pixel image (7 tiles of 16x16) with solid colors.
No external dependencies — uses only Python stdlib (struct, zlib).

Tiles:
  0: Grass    (#4a8c3f)
  1: Dirt     (#8b6914)
  2: Water    (#3a6cb0)
  3: Stone    (#6b6b6b)
  4: Sand     (#d4b96a)
  5: Wood     (#6d4c2a)
  6: Farmland (#5a3a1a)

Usage:
  python tools/generate_placeholder_tiles.py
"""

import struct
import zlib
import os

TILE_SIZE = 16
TILE_COUNT = 7
WIDTH = TILE_SIZE * TILE_COUNT  # 112
HEIGHT = TILE_SIZE  # 16

# (R, G, B) for each tile
TILE_COLORS = [
    (0x4A, 0x8C, 0x3F),  # 0: Grass
    (0x8B, 0x69, 0x14),  # 1: Dirt
    (0x3A, 0x6C, 0xB0),  # 2: Water
    (0x6B, 0x6B, 0x6B),  # 3: Stone
    (0xD4, 0xB9, 0x6A),  # 4: Sand
    (0x6D, 0x4C, 0x2A),  # 5: Wood
    (0x5A, 0x3A, 0x1A),  # 6: Farmland
]


def create_png(width: int, height: int, pixels: list[tuple[int, int, int]]) -> bytes:
    """Create a minimal valid PNG from RGB pixel data."""

    def chunk(chunk_type: bytes, data: bytes) -> bytes:
        c = chunk_type + data
        crc = struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
        return struct.pack(">I", len(data)) + c + crc

    # PNG signature
    sig = b"\x89PNG\r\n\x1a\n"

    # IHDR: width, height, bit_depth=8, color_type=2 (RGB), compression=0, filter=0, interlace=0
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    ihdr = chunk(b"IHDR", ihdr_data)

    # IDAT: image data with filter byte 0 (None) per row
    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0)  # filter byte: None
        for x in range(width):
            r, g, b = pixels[y * width + x]
            raw_data.extend([r, g, b])

    compressed = zlib.compress(bytes(raw_data))
    idat = chunk(b"IDAT", compressed)

    # IEND
    iend = chunk(b"IEND", b"")

    return sig + ihdr + idat + iend


def main() -> None:
    # Build pixel array
    pixels: list[tuple[int, int, int]] = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            tile_index = x // TILE_SIZE
            pixels.append(TILE_COLORS[tile_index])

    png_data = create_png(WIDTH, HEIGHT, pixels)

    # Write to assets/tilesets/
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_path = os.path.join(project_root, "assets", "tilesets", "placeholder_tiles.png")

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "wb") as f:
        f.write(png_data)

    print(f"Created {output_path} ({len(png_data)} bytes, {WIDTH}x{HEIGHT})")


if __name__ == "__main__":
    main()
