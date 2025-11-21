#!/usr/bin/env python3
"""
convert_warc_gz.py

Convert Archive-It .warc.gz files into uncompressed .warc files.

Usage examples:

    # Extract all .warc.gz files in a collection folder into an Extracted subfolder
    python convert_warc_gz.py "C:\\WARCs\\Collection-2568" -o "C:\\WARCs\\Collection-2568\\Extracted"

    # Extract a single .warc.gz file
    python convert_warc_gz.py "C:\\WARCs\\file.warc.gz" -o "C:\\WARCs\\Extracted"
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
    os.makedirs(path, exist_ok=True)


def compute_output_path(input_path: str, output_dir: Optional[str] = None) -> str:
    """
    Given an input .warc.gz file and an optional output directory,
    return the full output .warc path.
    """
    dirname, filename = os.path.split(input_path)

    # Strip only the .gz part, keep .warc
    if filename.lower().endswith(".gz"):
        base_name = filename[:-3]  # removes '.gz'
    else:
        base_name = filename

    if output_dir:
        ensure_output_dir(output_dir)
        return os.path.join(output_dir, base_name)
    else:
        return os.path.join(dirname, base_name)


def convert_single_file(input_path: str, output_path: str, overwrite: bool = False) -> Tuple[bool, str]:
    """
    Convert a single .warc.gz file to .warc.
    Returns (success: bool, message: str).
    """
    if not os.path.isfile(input_path):
        return False, f"[X] INPUT NOT FOUND: {input_path}"

    if not is_warc_gz(input_path):
        return False, f"[X] SKIPPING (not .warc.gz): {input_path}"

    if os.path.exists(output_path) and not overwrite:
        return False, f"[!] SKIPPING (output exists): {output_path}"

    try:
        print(f"[+] Extracting:")
        print(f"    IN  = {input_path}")
        print(f"    OUT = {output_path}")

        # Ensure directory exists
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        with gzip.open(input_path, "rb") as f_in:
            with open(output_path, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)

        return True, f"[✓] DONE: {output_path}"

    except Exception as e:
        return False, f"[X] ERROR converting {input_path}: {e}"


def convert_folder(folder_path: str, output_dir: Optional[str], overwrite: bool) -> None:
    """
    Convert all .warc.gz files in a single folder (non-recursive).
    """
    if not os.path.isdir(folder_path):
        print(f"[X] ERROR: Folder does not exist: {folder_path}")
        return

    print(f"[+] Scanning folder: {folder_path}")

    if output_dir:
        ensure_output_dir(output_dir)

    # Only look for .warc.gz at the top level
    warc_gz_files = [
        os.path.join(folder_path, f)
        for f in os.listdir(folder_path)
        if is_warc_gz(f)
    ]

    if not warc_gz_files:
        print("[X] ERROR: No .warc.gz files were found in this folder.")
        return

    total = len(warc_gz_files)
    print(f"[+] Found {total} .warc.gz file(s) to extract.\n")

    successes = 0
    failures = 0
    skipped = 0

    for idx, file_path in enumerate(warc_gz_files, start=1):
        filename = os.path.basename(file_path)
        print(f"--- [{idx}/{total}] ----------------------------")

        out_path = compute_output_path(file_path, output_dir)
        ok, msg = convert_single_file(file_path, out_path, overwrite=overwrite)

        print(msg)
        print()

        if ok:
            successes += 1
        else:
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
        description="Convert .warc.gz files in a folder into .warc files."
    )
    parser.add_argument(
        "input",
        help="Path to a .warc.gz file or a folder containing .warc.gz files."
    )
    parser.add_argument(
        "-o", "--output",
        dest="output_dir",
        help="Output folder for the extracted .warc files."
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

    # If input is a directory → extract folder mode
    if os.path.isdir(input_path):
        convert_folder(input_path, output_dir=output_dir, overwrite=args.overwrite)
        return

    # Otherwise, treat as single file extraction
    if not is_warc_gz(input_path):
        print(f"[X] ERROR: Input is not a .warc.gz file: {input_path}")
        return

    out_path = compute_output_path(input_path, output_dir)
    ok, msg = convert_single_file(input_path, out_path, overwrite=args.overwrite)
    print(msg)


if __name__ == "__main__":
    main()
