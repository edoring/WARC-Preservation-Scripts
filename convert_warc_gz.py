#!/usr/bin/env python3
"""
convert_warc_gz.py

Convert Archive-It .warc.gz files into uncompressed .warc files.

Usage examples:

    # Extract all .warc.gz files in a collection folder into an Extracted subfolder
    python convert_warc_gz.py "C:\\WARCs\\Collection-2568" -o "C:\\WARCs\\Collection-2568\\Extracted"

    # Extract a single .warc.gz file (output .warc goes next to it unless -o is given)
    python convert_warc_gz.py "C:\\WARCs\\ARCHIVEIT-2568-20110428.warc.gz"

This script is designed to be run from the root of the WARC-Preservation-Scripts repository.
"""

import os
import gzip
import shutil
import argparse
from typing import Optional, Tuple


def is_warc_gz(path: str) -> bool:
    """Return True if the path looks like a .warc.gz file (case-insensitive)."""
    return path.lower().endswith(".warc.gz")


def ensure_output_dir(path: str) -> None:
    """Create the output directory if it does not already exist."""
    if not os.path.isdir(path):
        os.makedirs(path, exist_ok=True)


def compute_output_path(
    input_path: str,
    output_dir: Optional[str] = None
) -> str:
    """
    Given an input .warc.gz path and an optional output directory,
    return the full output .warc path.

    - If output_dir is provided, the .warc is written there.
    - Otherwise, the .warc is written alongside the input file.
    """
    dirname, filename = os.path.split(input_path)

    # Strip only the .gz extension, keep .warc
    if filename.lower().endswith(".gz"):
        base_name = filename[:-3]  # remove trailing ".gz"
    else:
        base_name = filename

    if output_dir:
        ensure_output_dir(output_dir)
        return os.path.join(output_dir, base_name)
    else:
        return os.path.join(dirname, base_name)


def convert_single_file(
    input_path: str,
    output_path: str,
    overwrite: bool = False
) -> Tuple[bool, str]:
    """
    Convert a single .warc.gz file to .warc.

    Returns (success, message).
    """
    if not os.path.isfile(input_path):
        return False, f"[!] INPUT NOT FOUND: {input_path}"

    if not is_warc_gz(input_path):
        return False, f"[!] SKIPPING (not .warc.gz): {input_path}"

    if os.path.exists(output_path) and not overwrite:
        return False, f"[!] SKIPPING (output exists): {output_path}"

    try:
        print(f"[+] Extracting:")
        print(f"    IN  = {input_path}")
        print(f"    OUT = {output_path}")

        # Make sure parent directory for output exists
        out_dir = os.path.dirname(output_path)
        if out_dir and not os.path.isdir(out_dir):
            os.makedirs(out_dir, exist_ok=True)

        with gzip.open(input_path, "rb") as f_in:
            with open(output_path, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)

        return True, f"[✓] DONE: {output_path}"
    except Exception as e:
        return False, f"[X] ERROR converting {input_path}: {e}"


def convert_folder(
    folder_path: str,
    output_dir: Optional[str] = None,
    overwrite: bool = False
) -> None:
    """
    Convert all .warc.gz files in a single folder (non-recursive) to .warc.

    - folder_path: directory containing .warc.gz files
    - output_dir:  where to place .warc files (if None, use folder_path)
    """
    if not os.path.isdir(folder_path):
        print(f"[X] ERROR: Folder does not exist: {folder_path}")
        return

    print(f"[+] Scanning folder: {folder_path}")
    if output_dir:
        print(f"[+] Output folder: {output_dir}")
        ensure_output_dir(output_dir)

    warc_gz_files = [
        f for f in os.listdir(folder_path)
        if is_warc_gz(f)
    ]

    if not warc_gz_files:
        print("[!] No .warc.gz files found in this folder.")
        return

    total = len(warc_gz_files)
    print(f"[+] Found {total} .warc.gz file(s) to extract.\n")

    successes = 0
    failures = 0
    skipped = 0

    for idx, filename in enumerate(warc_gz_files, start=1):
        input_path = os.path.join(folder_path, filename)
        out_path = compute_output_path(input_path, output_dir)

        print(f"--- [{idx}/{total}] ----------------------------")
        ok, msg = convert_single_file(input_path, out_path, overwrite=overwrite)
        print(msg)
        print()

        if ok:
            successes += 1
        else:
            # classify a bit: existing output counts as 'skipped', others as 'failed'
            if "SKIPPING (output exists)" in msg:
                skipped += 1
            else:
                failures += 1

    print("======================================")
    print(" WARC EXTRACTION SUMMARY")
    print("======================================")
    print(f"  Total .warc.gz files: {total}")
    print(f"  Successfully extracted: {successes}")
    print(f"  Skipped (output exists): {skipped}")
    print(f"  Failed: {failures}")
    print("======================================")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert .warc.gz files in a collection folder to .warc."
    )
    parser.add_argument(
        "input",
        help="Path to a .warc.gz file OR a folder containing .warc.gz files."
    )
    parser.add_argument(
        "-o",
        "--output",
        dest="output_dir",
        help="Optional output folder for .warc files. "
             "If omitted, .warc files are written next to the inputs."
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing .warc files if they already exist."
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    input_path = os.path.abspath(args.input)
    output_dir = os.path.abspath(args.output_dir) if args.output_dir else None

    if os.path.isdir(input_path):
        convert_folder(input_path, output_dir=output_dir, overwrite=args.overwrite)
    else:
        # Single-file mode (still allowed, even though your docs emphasize collections)
        if not is_warc_gz(input_path):
            print(f"[X] ERROR: Input is not a .warc.gz file: {input_path}")
            return

        out_path = compute_output_path(input_path, output_dir)
        ok, msg = convert_single_file(input_path, out_path, overwrite=args.overwrite)
        print(msg)


if __name__ == "__main__":
    main()
