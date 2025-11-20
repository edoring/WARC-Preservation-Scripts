#!/usr/bin/env python

import os
import gzip
from urllib.parse import urlparse

from warcio.archiveiterator import ArchiveIterator
from openpyxl import Workbook


def iter_warc_files(input_path, recursive=False):
    """
    Yield full paths to .warc and .warc.gz files from a file or directory.
    """
    if os.path.isfile(input_path):
        if input_path.lower().endswith((".warc", ".warc.gz")):
            yield os.path.abspath(input_path)
        else:
            print(f"[!] Skipping non-WARC file: {input_path}")
        return

    if not os.path.isdir(input_path):
        print(f"[!] Input path is not valid: {input_path}")
        return

    if recursive:
        for root, _, files in os.walk(input_path):
            for name in files:
                if name.lower().endswith((".warc", ".warc.gz")):
                    yield os.path.join(root, name)
    else:
        for name in os.listdir(input_path):
            full = os.path.join(input_path, name)
            if os.path.isfile(full) and name.lower().endswith((".warc", ".warc.gz")):
                yield full


def choose_recommended_seed(urls):
    """
    Pick a 'content' seed URL for this host based on:
      - no query string
      - shallowest path
      - https preferred over http
      - shorter length as tie-break

    This is the best candidate like http://www.ok.gov/omvc/
    """
    def score(url):
        parsed = urlparse(url)
        path = parsed.path or ""
        trimmed = path.strip("/")
        depth = 0 if trimmed == "" else len(trimmed.split("/"))
        has_query = 1 if parsed.query else 0
        scheme_penalty = 0 if parsed.scheme == "https" else 1
        length = len(url)
        return (has_query, depth, scheme_penalty, length)

    return sorted(urls, key=score)[0]


def choose_root_seed(urls):
    """
    Always return ROOT seed as scheme://host/
    Prefer https if any URL uses https.
    """
    parsed_list = [urlparse(u) for u in urls if urlparse(u).netloc]
    if not parsed_list:
        return None

    netloc = parsed_list[0].netloc
    # Prefer https if present, else use first scheme or http
    if any(p.scheme == "https" for p in parsed_list):
        scheme = "https"
    else:
        scheme = parsed_list[0].scheme or "http"

    return f"{scheme}://{netloc}/"


def process_warc_file(warc_path):
    """
    Process a single WARC/WARC.GZ file and return:
        host -> set(urls)
    """
    host_urls = {}

    open_func = gzip.open if warc_path.lower().endswith(".gz") else open

    print(f"[*] Processing {warc_path} ...")
    try:
        with open_func(warc_path, "rb") as stream:
            for record in ArchiveIterator(stream):
                if record.rec_type != "response":
                    continue

                url = record.rec_headers.get_header("WARC-Target-URI")
                if not url:
                    continue

                parsed = urlparse(url)
                host = parsed.netloc.lower()
                if not host:
                    continue

                if host not in host_urls:
                    host_urls[host] = set()
                host_urls[host].add(url)

    except Exception as e:
        print(f"[!] ERROR reading {warc_path}: {e}")

    return host_urls


def write_excel(all_rows, primary_rows, output_path):
    """
    Write results to an Excel file (.xlsx) with:
      - Sheet 1: all hosts
      - Sheet 2: one primary root + content seed per WARC
    """
    wb = Workbook()

    # Sheet 1: All hosts
    ws_all = wb.active
    ws_all.title = "All Hosts"

    headers_all = [
        "warc_file",
        "host",
        "recommended_seed_url",   # per-host content-like URL
        "total_urls_for_host",
        "example_urls",
        "is_primary",
    ]
    ws_all.append(headers_all)

    for row in all_rows:
        ws_all.append([
            row["warc_file"],
            row["host"],
            row["recommended_seed_url"],
            row["total_urls_for_host"],
            row["example_urls"],
            "YES" if row["is_primary"] else "NO",
        ])

    # Sheet 2: Primary seeds per WARC
    ws_primary = wb.create_sheet(title="Primary Seeds")

    headers_primary = [
        "warc_file",
        "primary_host",
        "primary_seed_root_url",      # scheme://host/
        "primary_seed_content_url",   # e.g. http://www.ok.gov/omvc/
        "total_urls_for_primary_host",
        "number_of_hosts_in_warc",
    ]
    ws_primary.append(headers_primary)

    for row in primary_rows:
        ws_primary.append([
            row["warc_file"],
            row["primary_host"],
            row["primary_seed_root_url"],
            row["primary_seed_content_url"],
            row["total_urls_for_primary_host"],
            row["number_of_hosts_in_warc"],
        ])

    wb.save(output_path)
    print(f"\n[+] Excel file saved as: {output_path}\n")


def main():
    print("\n=== WARC Seed Helper ===")
    print("This tool scans your WARC files and finds:")
    print(" - a ROOT seed (scheme://host/)")
    print(" - a CONTENT seed (shallowest real page, e.g. /omvc/)\n")

    # Ask user for input path
    input_path = input("Enter the FULL path to your WARC file or folder:\n> ").strip()

    # Ask about recursion
    recursive_input = input("\nSearch inside subfolders too? (y/n): ").strip().lower()
    recursive = recursive_input.startswith("y")

    # Figure out where to save Excel:
    # - If input is a folder, use that folder
    # - If input is a file, use the folder that file is in
    if os.path.isdir(input_path):
        base_dir = os.path.abspath(input_path)
    else:
        base_dir = os.path.dirname(os.path.abspath(input_path))

    output_excel = os.path.join(base_dir, "warc_seed_report.xlsx")

    print("\nScanning for WARC files...\n")

    warc_files = list(iter_warc_files(input_path, recursive=recursive))
    if not warc_files:
        print("[!] No WARC files found. Check your path.")
        return

    print(f"[+] Found {len(warc_files)} WARC file(s). Starting...\n")

    all_rows = []      # all hosts for all warcs
    primary_rows = []  # one primary host per warc

    for warc_path in warc_files:
        host_urls = process_warc_file(warc_path)
        warc_name = os.path.basename(warc_path)

        if not host_urls:
            print(f"    [!] No URLs found in {warc_path}")
            continue

        # Determine which host is PRIMARY for this WARC: host with most URLs
        primary_host = None
        primary_count = -1
        for host, urls in host_urls.items():
            count = len(urls)
            if count > primary_count:
                primary_count = count
                primary_host = host

        number_of_hosts = len(host_urls)

        # Build per-host rows and mark primary
        for host, urls in sorted(host_urls.items()):
            recommended = choose_recommended_seed(urls)   # content-like URL
            total = len(urls)
            examples = sorted(urls)[:5]
            example_str = " | ".join(examples)

            is_primary = (host == primary_host)

            if is_primary:
                root_seed = choose_root_seed(urls)
                print(
                    f"    [*] PRIMARY {warc_name} | HOST: {host} | "
                    f"ROOT SEED: {root_seed} | CONTENT SEED: {recommended} | {total} URLs"
                )
            else:
                print(
                    f"    [+] {warc_name} | HOST: {host} | "
                    f"RECOMMENDED CONTENT SEED: {recommended} | {total} URLs"
                )

            all_rows.append(
                {
                    "warc_file": warc_name,
                    "host": host,
                    "recommended_seed_url": recommended,
                    "total_urls_for_host": total,
                    "example_urls": example_str,
                    "is_primary": is_primary,
                }
            )

        # Add one row per WARC for the "Primary Seeds" sheet
        primary_urls = host_urls[primary_host]
        primary_root_seed = choose_root_seed(primary_urls)
        primary_content_seed = choose_recommended_seed(primary_urls)

        primary_rows.append(
            {
                "warc_file": warc_name,
                "primary_host": primary_host,
                "primary_seed_root_url": primary_root_seed,
                "primary_seed_content_url": primary_content_seed,
                "total_urls_for_primary_host": len(primary_urls),
                "number_of_hosts_in_warc": number_of_hosts,
            }
        )

    if all_rows:
        write_excel(all_rows, primary_rows, output_excel)
    else:
        print("[!] No usable URL data extracted.\n")

    print("Done!\n")


if __name__ == "__main__":
    main()
