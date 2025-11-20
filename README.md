# 📦 WARC Preservation Toolkit  
*A step-by-step workflow for downloading, extracting, renaming, and analyzing Archive-It WARC files.*

[![Documentation](https://img.shields.io/badge/Documentation-Wiki-blue?style=for-the-badge)](https://github.com/edoring/WARC-Preservation-Scripts/wiki)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)]()
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey?style=for-the-badge)]()

---

## 📚 Full Documentation  
📘 **Complete step-by-step instructions:**  
➡️ https://github.com/edoring/WARC-Preservation-Scripts/wiki  

---

## 📝 Overview  
This toolkit provides a straightforward, repeatable workflow for processing Archive-It WARC files in a Windows environment.  
It includes scripts for:

- Downloading WARC files by collection  
- Extracting `.warc.gz` files into `.warc` format  
- Renaming WARCs using agency name + capture date  
- Identifying seed URLs for each capture  
- Producing clean metadata for preservation systems  

---

## 🔧 Features  
- ✔ **Simple PowerShell scripts**  
- ✔ **Python automation integrated into PowerShell** (no Python commands required)  
- ✔ **Clear on-screen prompts**  
- ✔ **Renamed files saved separately for safety**  
- ✔ **Automatic metadata CSV generation**  
- ✔ **Seed URL extraction with warnings for missing or multiple seeds**  
- ✔ **Staff-friendly documentation**  

---

## 🗂 Quick Links (Wiki)

- **[Home – Overview](https://github.com/edoring/WARC-Preservation-Scripts/wiki)**
- **[Step 1 – Download WARC Files](https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-1-Download-WARC-Files)**
- **[Step 2 – Extract WARC Files](https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-2-Extract-WARC-Files)**
- **[Step 3 – Rename WARC Files](https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-3-Rename-WARC-Files)**
- **[Step 4 – Identify Seed URLs](https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-4-Identify-Seed-URLs)**


---

## 🗃 Included Scripts  
- `1_Download-WARCs-ByCollection.ps1` — Download WARCs from Archive-It  
- `2_Extract-Folder-Warcs.ps1` — Extract `.warc.gz`  
- `3_Rename_WARCs.ps1` — Rename WARCs + create metadata  
- `4_Identify-Seeds.ps1` — Identify seed URLs + create CSV  
- `rename_warcs_copy_agency.py` — Automatic renaming backend  
- `warc_seed_tools.py` — Automatic seed-detection backend  
- `wget.exe` — Helper tool  
- `jq.exe` — Helper tool  

---

## 🖥 System Requirements  
- Windows 10 or Windows 11  
- PowerShell  
- Python 3.10+  
- Archive-It API Key  
- Sufficient storage for large collections  

---

## 🆘 Support  
For questions, issues, or improvements, open a request in the “Issues” tab of the repository.

---

## ✨ Credits  
Created by **Elizabeth Doring**  
Oklahoma Department of Libraries Archivist


## 🔄 Workflow Diagram

