<# 
3_Extract-Collection-WARCs_Python.ps1

Interactive PowerShell wrapper for convert_warc_gz.py.

- Prompts for a collection folder containing .warc.gz files
- Extracts all .warc.gz files to an "Extracted" subfolder (or custom output folder)
- Calls: python convert_warc_gz.py "<collection>" -o "<output>"

Designed to be run by right-clicking "Run with PowerShell" from the repository root.
#>

param()

Write-Host "========================================="
Write-Host "  STEP 3 – EXTRACT COLLECTION WARCs"
Write-Host "  (Python-based extraction)"
Write-Host "========================================="
Write-Host ""

# Resolve the directory where this script lives (repo root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "convert_warc_gz.py"

if (-not (Test-Path $PythonScript)) {
    Write-Host "[X] ERROR: Could not find convert_warc_gz.py in:" -ForegroundColor Red
    Write-Host "    $ScriptDir"
    Write-Host "Make sure this script and convert_warc_gz.py are in the same folder."
    exit 1
}

# Check that Python is available
try {
    $pythonVersion = & python --version 2>$null
    if (-not $pythonVersion) {
        throw "Python not found"
    }
    Write-Host "[+] Python detected: $pythonVersion"
} catch {
    Write-Host "[X] ERROR: Python does not appear to be installed or is not on PATH." -ForegroundColor Red
    Write-Host "    Install Python 3.8+ and make sure 'python' works in PowerShell."
    exit 1
}

Write-Host ""

# Ask for the collection folder path
$CollectionPath = Read-Host "Enter the FULL path to the collection folder containing .warc.gz files"
$CollectionPath = $CollectionPath.Trim('"')

if (-not (Test-Path -Path $CollectionPath -PathType Container)) {
    Write-Host ""
    Write-Host "[X] ERROR: That folder does not exist or is not a directory:" -ForegroundColor Red
    Write-Host "    $CollectionPath"
    exit 1
}

# Default output folder = Collection\Extracted
$DefaultOutput = Join-Path $CollectionPath "Extracted"
Write-Host ""
Write-Host "Default output folder for extracted .warc files will be:"
Write-Host "    $DefaultOutput"
Write-Host ""

$OutputInput = Read-Host "Press ENTER to accept the default output folder, or type a custom folder path"
if ([string]::IsNullOrWhiteSpace($OutputInput)) {
    $OutputFolder = $DefaultOutput
} else {
    $OutputFolder = $OutputInput.Trim('"')
}

Write-Host ""
Write-Host "You are about to extract all .warc.gz files from:"
Write-Host "    $CollectionPath"
Write-Host "into:"
Write-Host "    $OutputFolder"
Write-Host ""

$Confirm = Read-Host "Proceed with extraction? (Y/N)"
if ($Confirm -notin @("Y", "y")) {
    Write-Host ""
    Write-Host "[!] Extraction cancelled by user."
    exit 0
}

Write-Host ""
Write-Host "========================================="
Write-Host "  Running Python extractor..."
Write-Host "========================================="
Write-Host ""

# Ensure output folder exists
if (-not (Test-Path -Path $OutputFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

# Build and run the Python command
$ArgsList = @(
    "`"$PythonScript`"",
    "`"$CollectionPath`"",
    "-o",
    "`"$OutputFolder`""
)

Write-Host "Command:"
Write-Host "python $($ArgsList -join ' ')"
Write-Host ""

# Actually run Python
& python @ArgsList

$ExitCode = $LASTEXITCODE

Write-Host ""
Write-Host "========================================="
Write-Host "  Extraction finished."
Write-Host "  Python exit code: $ExitCode"
Write-Host "========================================="

if ($ExitCode -ne 0) {
    Write-Host "[!] One or more errors may have occurred. Check the messages above." -ForegroundColor Yellow
} else {
    Write-Host "[✓] All done. Extracted .warc files should now be in:" -ForegroundColor Green
    Write-Host "    $OutputFolder"
}
