#!/usr/bin/env python3
r"""
Sync PocketPalette.csv from a local Return of Reckoning install.

Simple behavior:
- Requires shipped `PocketPalette.csv` as merge base (must exist).
- Requires `data.myp` under `--game-dir` (must exist and be compatible).
- Updates only hue/spec columns, keeps shipped CSV layout/header format.
- Uses configured hash pair first; if not found, auto-infers a compatible pair from `data.myp`.

Requirements:
- Python 3.8+
- No external dependencies (`pip install` not needed)

Examples:
- Linux:
  - Dry run:  python3 sync_shipped_csv.py --game-dir "/games/Return of Reckoning" --dry-run
  - Write:    python3 sync_shipped_csv.py --game-dir "/games/Return of Reckoning"
- macOS:
  - Dry run:  python3 sync_shipped_csv.py --game-dir "/Applications/Return of Reckoning" --dry-run
  - Write:    python3 sync_shipped_csv.py --game-dir "/Applications/Return of Reckoning"
- WSL:
  - Dry run:  python3 sync_shipped_csv.py --game-dir "/mnt/c/Return of Reckoning" --dry-run
  - Write:    python3 sync_shipped_csv.py --game-dir "/mnt/c/Return of Reckoning"
- Windows PowerShell:
  - Dry run:  py -3 .\sync_shipped_csv.py --game-dir "C:\Return of Reckoning" --dry-run
  - Write:    py -3 .\sync_shipped_csv.py --game-dir "C:\Return of Reckoning"
- Windows CMD:
  - Dry run:  py -3 sync_shipped_csv.py --game-dir "C:\Return of Reckoning" --dry-run
  - Write:    py -3 sync_shipped_csv.py --game-dir "C:\Return of Reckoning"
"""

import argparse
import csv
import io
import struct
import sys
import zlib
from pathlib import Path


DEFAULT_HASH_PAIR = "A8E69F8E#16A61412"
CSV_COLS = 19

HEADER_ROW_1 = [
    "ID", "Name", "Diffuse", "", "", "", "Specular", "", "", "", "Type", "Race", "", "", "", "", "", "", "",
]
HEADER_ROW_2 = [
    "ID", "Name",
    "DiffuseRed", "DiffuseGreen", "DiffuseBlue", "DiffuseIntensity",
    "SpecularRed", "SpecularGreen", "SpecularBlue", "SpecularIntensity",
    "Type",
    "RaceMonster", "RaceDwarf", "RaceOrc", "RaceGoblin",
    "RaceHighElf", "RaceDarkElf", "RaceEmpire", "RaceChaos",
]


def parse_hash_pair(value):
    parts = value.split("#")
    if len(parts) != 2:
        raise ValueError("hash pair must look like A8E69F8E#16A61412")
    return int(parts[0], 16), int(parts[1], 16)


def format_hash_pair(path_hash, short_hash):
    return "%08X#%08X" % (path_hash, short_hash)


def extract_from_myp(myp_path, hash_pair):
    want_ph, want_sh = parse_hash_pair(hash_pair)

    with myp_path.open("rb") as handle:
        handle.seek(0x0C)
        low, high = struct.unpack("<II", handle.read(8))
        table = low + (high << 32)

        while table:
            handle.seek(table)
            header = handle.read(12)
            if len(header) != 12:
                break

            num, next_low, next_high = struct.unpack("<III", header)
            next_table = next_low + (next_high << 32)
            current = table + 12
            end = current + (34 * num)

            while current < end:
                handle.seek(current)
                entry = handle.read(34)
                if len(entry) != 34:
                    break

                start_low, start_high, header_size, compressed_size, _ = struct.unpack_from("<IIIII", entry, 0)
                short_hash, path_hash = struct.unpack_from("<II", entry, 20)
                compression_flag = entry[32]

                if (
                    path_hash == want_ph
                    and short_hash == want_sh
                    and start_low > 0
                    and compressed_size > 0
                ):
                    start = start_low + (start_high << 32)
                    handle.seek(start + header_size)
                    data = handle.read(compressed_size)

                    if compression_flag == 1:
                        d = zlib.decompressobj()
                        data = d.decompress(data) + d.flush()
                    elif compression_flag != 0:
                        raise RuntimeError("unsupported compression flag: %s" % compression_flag)

                    return data

                current += 34

            table = next_table

    raise FileNotFoundError(
        "compatible tintpalette entry not found in %s using hash pair %s"
        % (myp_path, hash_pair)
    )


def decode_bytes(raw):
    for encoding in ("utf-8-sig", "utf-8", "cp1252", "latin-1"):
        try:
            return raw.decode(encoding)
        except UnicodeDecodeError:
            pass
    return raw.decode("latin-1", errors="replace")


def tintpalette_score(raw_bytes):
    text = decode_bytes(raw_bytes)
    lines = text.splitlines()
    if len(lines) < 3:
        return 0

    h1 = lines[0].lower()
    h2 = lines[1].lower()

    if "id,name" not in h1:
        return 0
    if "diffuse" not in h1 or "specular" not in h1:
        return 0
    if "diffusered" not in h2 and "red,green,blue" not in h2:
        return 0

    score = 0
    for line in lines[2:]:
        if not line:
            continue
        first = line.split(",", 1)[0].strip()
        if first.isdigit():
            score += 1

    if score < 200:
        return 0
    return score


def infer_hash_pair_and_extract(myp_path):
    best_score = 0
    best_data = None
    best_pair = None

    with myp_path.open("rb") as handle:
        handle.seek(0x0C)
        low, high = struct.unpack("<II", handle.read(8))
        table = low + (high << 32)

        while table:
            handle.seek(table)
            header = handle.read(12)
            if len(header) != 12:
                break

            num, next_low, next_high = struct.unpack("<III", header)
            next_table = next_low + (next_high << 32)
            current = table + 12
            end = current + (34 * num)

            while current < end:
                handle.seek(current)
                entry = handle.read(34)
                if len(entry) != 34:
                    break

                start_low, start_high, header_size, compressed_size, _ = struct.unpack_from("<IIIII", entry, 0)
                short_hash, path_hash = struct.unpack_from("<II", entry, 20)
                compression_flag = entry[32]

                if start_low <= 0 or compressed_size <= 0:
                    current += 34
                    continue
                if compression_flag not in (0, 1):
                    current += 34
                    continue
                if compressed_size > 2_000_000:
                    current += 34
                    continue

                start = start_low + (start_high << 32)
                handle.seek(start + header_size)
                data = handle.read(compressed_size)

                if compression_flag == 1:
                    d = zlib.decompressobj()
                    data = d.decompress(data) + d.flush()

                score = tintpalette_score(data)
                if score > best_score:
                    best_score = score
                    best_data = data
                    best_pair = format_hash_pair(path_hash, short_hash)

                current += 34

            table = next_table

    if best_data is None or best_pair is None:
        raise FileNotFoundError("could not infer tintpalette hash pair from %s" % myp_path)

    return best_data, best_pair


def pad_row(row):
    out = list(row)
    if len(out) < CSV_COLS:
        out.extend([""] * (CSV_COLS - len(out)))
    return out[:CSV_COLS]


def load_data_rows_from_text(text, name):
    rows = list(csv.reader(io.StringIO(text)))
    if len(rows) < 2:
        raise RuntimeError("invalid CSV in %s (expected 2 header rows)" % name)

    data = {}
    for row in rows[2:]:
        if not row:
            continue
        row = pad_row(row)
        try:
            dye_id = int(row[0])
        except Exception:
            continue
        data[dye_id] = row
    return data


def load_data_rows_from_file(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    return load_data_rows_from_text(text, str(path))


def merge_rows(base_rows, source_rows):
    merged = {k: v[:] for k, v in base_rows.items()}
    added = 0
    updated = 0

    for dye_id, src in source_rows.items():
        if dye_id not in merged:
            merged[dye_id] = pad_row(src)
            added += 1
            continue

        dst = merged[dye_id]
        changed = False
        for col in range(2, 10):
            if dst[col] != src[col]:
                dst[col] = src[col]
                changed = True
        if changed:
            updated += 1

    return merged, added, updated


def write_output_csv(path, merged_rows):
    out_rows = [HEADER_ROW_1[:], HEADER_ROW_2[:]]
    for dye_id in sorted(merged_rows):
        out_rows.append(pad_row(merged_rows[dye_id]))

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, lineterminator="\r\n")
        writer.writerows(out_rows)


def default_game_dir():
    if sys.platform.startswith("win"):
        return Path("C:/Return of Reckoning")
    return Path("/mnt/c/Return of Reckoning")


def main():
    default_base = Path(__file__).resolve().parent / "PocketPalette.csv"
    default_dir = default_game_dir()

    parser = argparse.ArgumentParser(
        description="Sync PocketPalette.csv from data.myp in a game install directory."
    )
    parser.add_argument(
        "--game-dir",
        type=Path,
        default=default_dir,
        help="Return of Reckoning install dir (default: %s)." % default_dir,
    )
    parser.add_argument(
        "--base-csv",
        type=Path,
        default=default_base,
        help="Shipped PocketPalette.csv merge base (required).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=default_base,
        help="Output CSV path (default: ./PocketPalette.csv).",
    )
    parser.add_argument(
        "--hash-pair",
        default=DEFAULT_HASH_PAIR,
        help="Hash pair used inside data.myp (default: %s)." % DEFAULT_HASH_PAIR,
    )
    parser.add_argument("--dry-run", action="store_true", help="Show summary only; do not write.")
    args = parser.parse_args()

    game_dir = args.game_dir.expanduser().resolve()
    base_csv = args.base_csv.expanduser().resolve()
    output_csv = args.output.expanduser().resolve()
    myp_path = game_dir / "data.myp"

    if not base_csv.exists():
        parser.error(
            "missing required shipped base CSV: %s\n"
            "This script depends on shipped PocketPalette.csv." % base_csv
        )
    if not game_dir.exists():
        parser.error("game dir does not exist: %s" % game_dir)
    if not myp_path.exists():
        parser.error("missing required file: %s" % myp_path)

    try:
        pair_used = args.hash_pair
        pair_mode = "configured"

        try:
            source_bytes = extract_from_myp(myp_path, args.hash_pair)
        except FileNotFoundError:
            source_bytes, pair_used = infer_hash_pair_and_extract(myp_path)
            pair_mode = "inferred"

        source_text = decode_bytes(source_bytes)
        source_rows = load_data_rows_from_text(source_text, str(myp_path))
        base_rows = load_data_rows_from_file(base_csv)
        merged_rows, added_rows, updated_rows = merge_rows(base_rows, source_rows)
    except Exception as exc:
        print("ERROR: %s" % exc, file=sys.stderr)
        return 1

    if args.dry_run:
        print("DRY RUN")
        print("Source (required): %s" % myp_path)
        print("Hash pair (%s): %s" % (pair_mode, pair_used))
        print("Base (required): %s" % base_csv)
        print("Would write: %s" % output_csv)
        print("Added rows: %d" % added_rows)
        print("Updated rows: %d" % updated_rows)
        print("Total rows: %d" % len(merged_rows))
        return 0

    write_output_csv(output_csv, merged_rows)
    print("Done.")
    print("Source (required): %s" % myp_path)
    print("Hash pair (%s): %s" % (pair_mode, pair_used))
    print("Base (required): %s" % base_csv)
    print("Wrote: %s" % output_csv)
    print("Added rows: %d" % added_rows)
    print("Updated rows: %d" % updated_rows)
    print("Total rows: %d" % len(merged_rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
