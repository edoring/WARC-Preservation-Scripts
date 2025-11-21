# ==========================================
# Extract-Folder-Warcs.ps1
# Deliberate bulk extractor for .warc.gz files
# - Prompts for a folder
# - Optionally recurses into subfolders
# - For each .warc.gz, creates an Extracted\ subfolder next to it
# - Uses 7-Zip CLI (no GUI, no .open files)
# - Keeps original .warc.gz files untouched
# ==========================================

# Prompt for folder containing .warc.gz files
$folderPath = Read-Host "Enter the FULL path to the folder containing .warc.gz files"

if (-not (Test-Path $folderPath)) {
    Write-Host "ERROR: Folder not found at '$folderPath'." -ForegroundColor Red
    exit 1
}

# Ask whether to recurse into subfolders
$recurseAnswer = Read-Host "Include subfolders? (Y/N)"
$recurse = $false
if ($recurseAnswer.ToUpper() -eq "Y") {
    $recurse = $true
}

# Path to 7-Zip CLI
$SevenZip = "C:\Program Files\7-Zip\7z.exe"

if (-not (Test-Path $SevenZip)) {
    Write-Host "ERROR: 7-Zip not found at $SevenZip. Install 7-Zip or adjust the path in this script." -ForegroundColor Red
    exit 1
}

Write-Host "Using 7-Zip at: $SevenZip" -ForegroundColor Cyan

# Get list of .warc.gz files
if ($recurse) {
    $files = Get-ChildItem -Path $folderPath -Filter *.warc.gz -Recurse
} else {
    $files = Get-ChildItem -Path $folderPath -Filter *.warc.gz
}

if (-not $files -or $files.Count -eq 0) {
    Write-Host "No .warc.gz files found in the specified folder (recurse = $recurse)." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($files.Count) .warc.gz file(s) to extract." -ForegroundColor Green
Write-Host ""

# Confirm before doing bulk extraction
$confirm = Read-Host "Proceed with extraction? This will create Extracted\ folders next to each file. (Y/N)"
if ($confirm.ToUpper() -ne "Y") {
    Write-Host "Extraction cancelled by user." -ForegroundColor Yellow
    exit 0
}

foreach ($file in $files) {
    $sourcePath = $file.FullName
    $sourceDir  = Split-Path $sourcePath -Parent
    $extractDir = Join-Path $sourceDir "Extracted"

    if (-not (Test-Path $extractDir)) {
        New-Item -ItemType Directory -Path $extractDir | Out-Null
    }

    Write-Host "Extracting:" -ForegroundColor Cyan
    Write-Host "  Source : $sourcePath"
    Write-Host "  Output : $extractDir"
    Write-Host ""

    # Run 7-Zip (CLI) to extract THIS file into its Extracted\ folder
    & "$SevenZip" "e" "$sourcePath" "-o$extractDir" "-y"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  -> Success" -ForegroundColor Green
    } else {
        Write-Host "  -> 7-Zip reported an error. Exit code: $LASTEXITCODE" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "Bulk extraction complete." -ForegroundColor Green
