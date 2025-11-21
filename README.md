📦 WARC Preservation Toolkit

A step-by-step workflow for downloading, verifying, extracting, renaming, and analyzing Archive-It WARC files.

📚 Full Documentation

📘 Complete step-by-step instructions:
➡️ https://github.com/edoring/WARC-Preservation-Scripts/wiki

📝 Overview

This toolkit provides a straightforward, repeatable workflow for processing Archive-It WARC files in a Windows environment.
It includes scripts for:

Downloading WARC files by collection

Verifying WARC download completeness and repairing missing/zero-byte files

Extracting .warc.gz files into .warc format

Renaming WARCs using agency name + capture date

Identifying seed URLs for each capture

📥 How to Download the Full Toolkit (Important)

To use this toolkit, you must download the entire folder to your computer.

Follow these steps:

Open the project page in your web browser
➜ https://github.com/edoring/WARC-Preservation-Scripts

Click the green Code button near the top right.

Select Download ZIP.

Save the ZIP file to your computer.

Right-click the ZIP file and choose Extract All…

Open the extracted folder.
This extracted folder contains everything you need:

PowerShell scripts

Python scripts

Helper tools (jq.exe, wget.exe)

Documentation

You will run all scripts from inside the extracted folder. No additional installation is required other than Python.

📥 How to Install Python (One-Time Setup)

Python is required for some of the tools, but you do not need to run Python directly. The PowerShell scripts will use it in the background.

Follow these steps:

Open a web browser and go to:
https://www.python.org/downloads/windows/

On that page, click the yellow button that says:
Download Python 3.x.x

When the file finishes downloading, open your Downloads folder.

Double-click the Python installer file (it will be named like python-3.x.x-amd64.exe).

On the first screen of the installer:

At the bottom, check the box that says:
Add Python to PATH

Then click Install Now

Wait for the installation to complete. This may take a few minutes.

When the installer says it is finished, click Close.

Restart your computer (this helps Windows recognize Python properly).

You only need to do this once on each computer.

🗂 Quick Links (Wiki)

Home – Overview

Step 1 – Download WARC Files

Step 2 – Verify & Repair Downloaded WARCs
 ← new!

Step 3 – Extract WARC Files

Step 4 – Rename WARC Files

Step 5 – Identify Seed URLs

🗃 Included Scripts

1_Download-WARCs-ByCollection.ps1 — Download WARCs from Archive-It

2_Check-WarcDownloads.ps1 — Verify download completeness, detect zero-byte files, and automatically re-download missing/partial WARCs

3_Extract-Folder-Warcs.ps1 — Extract .warc.gz

4_Rename_WARCs.ps1 — Rename WARCs + create metadata

5_Identify-Seeds.ps1 — Identify seed URLs + create CSV

rename_warcs_copy_agency.py — Automatic renaming backend

warc_seed_tools.py — Automatic seed-detection backend

wget.exe — Helper tool

jq.exe — Helper tool

🖥 System Requirements

Windows 10 or Windows 11

PowerShell

Python 3.10+

Archive-It API Key

Sufficient storage for large collections

✨ Credits

Created by Elizabeth Doring
Archivist — Oklahoma Department of Libraries


