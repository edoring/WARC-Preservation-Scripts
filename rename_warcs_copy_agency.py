import os
import re
import gzip
import shutil

def extract_date_from_filename(filename):
    # Looks for common Archive-It timestamp patterns: YYYYMMDDhhmmss
    match = re.search(r'(\d{8})\d{6}', filename)
    if match:
        return match.group(1)

    # Fallback: plain YYYYMMDD anywhere
    match = re.search(r'(\d{8})', filename)
    if match:
        return match.group(1)

    return None


def extract_date_from_warc(warc_path):
    try:
        opener = gzip.open if warc_path.endswith(".gz") else open
        with opener(warc_path, 'rb') as f:
            header = f.read(5000).decode(errors='ignore')
            match = re.search(r'WARC-Date:\s*(\d{4}-\d{2}-\d{2})', header)
            if match:
                return match.group(1).replace("-", "")
    except:
        return None

    return None


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

    for filename in os.listdir(folder):
        if not (filename.endswith(".warc") or filename.endswith(".warc.gz")):
            continue

        full_path = os.path.join(folder, filename)

        # Step 1: try filename date
        crawl_date = extract_date_from_filename(filename)

        # Step 2: try WARC header date
        if crawl_date is None:
            crawl_date = extract_date_from_warc(full_path)

        if crawl_date is None:
            print(f"Could not extract date for: {filename}")
            continue

        # Build new filename
        ext = ".warc.gz" if filename.endswith(".gz") else ".warc"
        new_filename = f"{agency}_{crawl_date}{ext}"
        new_path = os.path.join(output_folder, new_filename)

        print(f"Copying:\n  {filename}\n→ {new_filename}")
        shutil.copy2(full_path, new_path)

    print("\nDone. Originals untouched. Renamed copies stored in 'renamed'.")


if __name__ == "__main__":
    main()
