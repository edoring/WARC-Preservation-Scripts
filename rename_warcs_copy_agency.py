import os
import re
import gzip
import shutil


def extract_date_from_filename(filename):
    """
    Try to pull a date from the filename.

    1. Look for a 14-digit timestamp (YYYYMMDDhhmmss) and use the first 8 digits.
    2. If that fails, look for any 8-digit sequence (YYYYMMDD).
    """
    # Try full 14-digit timestamp first
    match = re.search(r'(\d{14})', filename)
    if match:
        return match.group(1)[:8]  # YYYYMMDD

    # Fallback: plain YYYYMMDD anywhere
    match = re.search(r'(\d{8})', filename)
    if match:
        return match.group(1)

    return None


def extract_date_from_warc(warc_path):
    """
    If no usable date is found in the filename, try reading the WARC header
    and pulling WARC-Date: YYYY-MM-DD...
    """
    try:
        opener = gzip.open if warc_path.endswith(".gz") else open
        with opener(warc_path, 'rb') as f:
            header = f.read(5000).decode(errors='ignore')
            match = re.search(r'WARC-Date:\s*(\d{4}-\d{2}-\d{2})', header)
            if match:
                return match.group(1).replace("-", "")
    except Exception as e:
        print(f"[!] Error reading WARC header for {os.path.basename(warc_path)}: {e}")
        return None

    return None


def make_unique_filename(output_folder, base_name, ext):
    """
    Ensure we don't overwrite files when multiple WARCs share the same date.

    Returns something like:
      AGENCY_20250107.warc
      AGENCY_20250107_2.warc
      AGENCY_20250107_3.warc
    """
    candidate = f"{base_name}{ext}"
    candidate_path = os.path.join(output_folder, candidate)

    if not os.path.exists(candidate_path):
        return candidate

    counter = 2
    while True:
        candidate = f"{base_name}_{counter}{ext}"
        candidate_path = os.path.join(output_folder, candidate)
        if not os.path.exists(candidate_path):
            return candidate
        counter += 1


def main():
    folder = input("Enter folder with WARCs: ").strip()
    if not os.path.isdir(folder):
        print("Invalid folder.")
        return

    agency = input("Enter agency name (e.g., ODSS, OSDH, OMES): ").strip()
    if not agency:
        print("Agency name cannot be empty.")
        return

    # Create output folder for renamed copies
    output_folder = os.path.join(folder, "renamed")
    os.makedirs(output_folder, exist_ok=True)

    # Get a stable, sorted list of files
    all_files = sorted(os.listdir(folder))

    total_candidates = 0
    processed = 0
    skipped_no_date = 0
    copy_errors = 0

    for filename in all_files:
        if not (filename.endswith(".warc") or filename.endswith(".warc.gz")):
            continue

        total_candidates += 1
        full_path = os.path.join(folder, filename)

        # Step 1: try filename date
        crawl_date = extract_date_from_filename(filename)

        # Step 2: try WARC header date
        if crawl_date is None:
            crawl_date = extract_date_from_warc(full_path)

        if crawl_date is None:
            print(f"[!] Could not extract date for: {filename}")
            skipped_no_date += 1
            continue

        # Build base name and unique filename
        ext = ".warc.gz" if filename.endswith(".gz") else ".warc"
        base_name = f"{agency}_{crawl_date}"
        unique_filename = make_unique_filename(output_folder, base_name, ext)
        new_path = os.path.join(output_folder, unique_filename)

        print(f"Copying ({processed + 1}):\n  {filename}\n→ {unique_filename}")
        try:
            shutil.copy2(full_path, new_path)
            processed += 1
        except Exception as e:
            print(f"[!] Error copying {filename}: {e}")
            copy_errors += 1
            continue

    print("\n===============================")
    print(" RENAMING SUMMARY")
    print("===============================")
    print(f"Total WARC candidates found: {total_candidates}")
    print(f"Successfully copied/renamed: {processed}")
    print(f"Skipped (no date found):     {skipped_no_date}")
    print(f"Copy errors:                 {copy_errors}")
    print(f"Output folder:               {output_folder}")
    print("Originals untouched. Renamed copies stored in 'renamed'.")


if __name__ == "__main__":
    main()
