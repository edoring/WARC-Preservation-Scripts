# 📦 WARC Preservation Toolkit  
*A guided workflow for downloading, verifying, extracting, renaming, and analyzing Archive-It WARC files.*

This toolkit provides a simple, reliable process for working with Archive-It WARC files on a Windows computer. Each step uses a script that prompts you for information—no coding experience is required.

---

## 🚀 What the Toolkit Does

The scripts in this toolkit help you:

- Download WARCs from an Archive-It collection  
- Check the completeness of your downloaded files  
- Extract compressed `.warc.gz` files  
- Create renamed copies of WARC files using a clear, consistent pattern  
- Identify primary seed URLs for each WARC  
- Generate structured metadata files (TXT, JSON, CSV, XLSX)  

All tools run through **PowerShell** using simple prompts.

---

## 📁 Included Tools

The toolkit folder contains:

- `1_Download-WARCs-ByCollection.ps1`  
- `2_Check-WarcDownloads.ps1`  
- `3_Extract-Folder-Warcs.ps1`  
- `4_Rename-WARCs.ps1`  
- `5_Identify-Seeds.ps1`  
- Python helpers:
  - `rename_warcs_copy_agency.py`
  - `warc_seed_tools.py`
- Helper executables:
  - `wget.exe`
  - `jq.exe`

No additional tools need to be downloaded.

---

## 📥 How to Download This Toolkit

1. Visit the repository:  
   **https://github.com/edoring/WARC-Preservation-Scripts**

2. Click the green **Code** button.

3. Select **Download ZIP**.

4. Save the ZIP and choose **Extract All…**

5. Open the extracted folder.  
   This folder contains all scripts and tools.

---

## 🐍 Python Installation (One-Time Setup)

Some scripts use Python automatically in the background.

To install Python:

1. Visit: https://www.python.org/downloads/windows/  
2. Click **Download Python 3.x.x**  
3. Run the installer  
4. Check the box: **Add Python to PATH**  
5. Click **Install Now**  
6. Restart your computer  

You only need to do this once.

---

## 🔧 Running the Scripts

All scripts in this toolkit are run the same way:

1. Open **File Explorer**  
2. Navigate to the Toolkit folder  
3. Right-click a script  
4. Select **Run with PowerShell**  
5. Follow the prompts  

Each script will guide you step by step.

---

## 📚 Full Documentation

The full workflow is documented in the GitHub Wiki:

👉 **https://github.com/edoring/WARC-Preservation-Scripts/wiki**

The workflow includes:

1. **Step 1 – Download WARC Files**  
2. **Step 2 – Verify & Repair Downloads**  
3. **Step 3 – Extract WARC Files**  
4. **Step 4 – Rename WARC Files**  
5. **Step 5 – Identify Seed URLs**  

Each page mirrors the scripts exactly so you always know what to expect.

---

## 🖥 System Requirements

- Windows 10 or Windows 11  
- PowerShell  
- Python 3.10+  
- Archive-It username and password  
- Archive-It collection ID  
- Adequate disk space for WARCs  

---

## ✨ Credits

Created and maintained by  
**Elizabeth Doring**  
Archivist – Oklahoma Department of Libraries  


