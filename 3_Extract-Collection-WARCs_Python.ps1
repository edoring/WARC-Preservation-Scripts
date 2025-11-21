<# 
3_Extract-Collection-WARCs_Python.ps1
Interactive PowerShell wrapper for convert_warc_gz.py.

- Prompts for collection folder containing .warc.gz files
- Creates an Extracted subfolder by default
- Calls Python with arguments after confirmation
#>

Write-Host "========================================="
Write-Host "  STEP 3 – EXTRACT COLLECTION WARCs"
Write-Host "  (Python-based extraction)"
Write-Host "========================================="
Write-Host ""

# Locate the Python script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "convert_warc_gz.py"

if (-not (Test-Path $PythonScript)) {
    Write-Host "[X] ERROR: Could not find convert_warc_gz.py in:" -ForegroundColor Red
    Write-Host "    $ScriptDir"
    exit
}

# Check Python
try {
    $ver = python --version 2>$null
    if (-not $ver) { throw "Python not found" }
    Write-Host "[+] Python detected: $ver"
} catch {
    Write-Host "[X] ERROR: Python is not installed or not on PATH." -ForegroundColor Red
    exit
}

Write-Host ""

# Ask for collection folder
$CollectionPath = Read-Host "Enter FULL path to the collection folder containing .warc.gz files"
$CollectionPath = $CollectionPath.Trim('"')

if (-not (Test-Path $CollectionPath)) {
    Write-Host "[X] ERROR: Folder does not exist:" -ForegroundColor Red
    Write-Host "    $CollectionPath"
    exit
}

# Default output folder
$DefaultOutput = Join-Path $CollectionPath "Extracted"
Write-Host ""
Write-Host "Default output folder:"
Write-Host "    $DefaultOutput"
Write-Host ""

$OutputInput = Read-Host "Press ENTER to accept default, or type a custom folder path"
if ([string]::IsNullOrWhiteSpace($OutputInput)) {
    $OutputFolder = $DefaultOutput
} else {
    $OutputFolder = $OutputInput.Trim('"')
}

Write-Host ""
Write-Host "Collection folder:  $CollectionPath"
Write-Host "Output folder:      $OutputFolder"
Write-Host ""

$Confirm = Read-Host "Proceed with extraction? (Y/N)"
if ($Confirm -notin @("Y","y")) {
    Write-Host "[!] Cancelled."
    exit
}

# Ensure output exists
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

Write-Host ""
Write-Host "========================================="
Write-Host "Running Python extractor..."
Write-Host "========================================="
Write-Host ""

# Run Python cleanly — safest argument format
python "`"$PythonScript`"" "`"$CollectionPath`"" -o "`"$OutputFolder`""

$ExitCode = $LASTEXITCODE
Write-Host ""
Write-Host "Finished with exit code: $ExitCode"
Write-Host ""

if ($ExitCode -eq 0) {
    Write-Host "[✓] Extraction complete!" -ForegroundColor Green
} else {
    Write-Host "[!] Extraction completed with warnings or errors." -ForegroundColor Yellow
}
