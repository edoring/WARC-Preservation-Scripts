# 3_Extract-Collection-WARCs_Python.ps1
# Interactive wrapper for convert_warc_gz.py with a progress bar.

Write-Host '========================================='
Write-Host '  STEP 3 - EXTRACT COLLECTION WARCs'
Write-Host '  (Python-based extraction with progress)'
Write-Host '========================================='
Write-Host ''

# Folder where this script lives
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$PythonScript = Join-Path $ScriptDir 'convert_warc_gz.py'

# Check that convert_warc_gz.py exists
if (-not (Test-Path $PythonScript)) {
    Write-Host 'ERROR: convert_warc_gz.py not found in:'
    Write-Host "  $ScriptDir"
    Read-Host 'Press ENTER to close'
    return
}

# Check that Python is available
$ver = $null
try {
    $ver = python --version 2>$null
} catch {
    $ver = $null
}

if (-not $ver) {
    Write-Host 'ERROR: Python is not installed or not on PATH.'
    Write-Host 'Make sure "python --version" works in PowerShell.'
    Read-Host 'Press ENTER to close'
    return
}

Write-Host "Python detected: $ver"
Write-Host ''

# Ask for the collection folder
$CollectionPath = Read-Host 'Enter FULL path to the collection folder containing .warc.gz files'
$CollectionPath = $CollectionPath.Trim('"')

if (-not (Test-Path -Path $CollectionPath -PathType Container)) {
    Write-Host ''
    Write-Host 'ERROR: Folder does not exist:'
    Write-Host "  $CollectionPath"
    Read-Host 'Press ENTER to close'
    return
}

# Find .warc.gz files at top level of the folder
$WarcGz = Get-ChildItem -Path $CollectionPath -Filter *.warc.gz -File -ErrorAction SilentlyContinue

if (-not $WarcGz -or $WarcGz.Count -eq 0) {
    Write-Host ''
    Write-Host 'ERROR: No .warc.gz files found in:'
    Write-Host "  $CollectionPath"
    Read-Host 'Press ENTER to close'
    return
}

# Default output folder = Collection\Extracted
$DefaultOutput = Join-Path $CollectionPath 'Extracted'
Write-Host ''
Write-Host 'Default output folder for extracted .warc files:'
Write-Host "  $DefaultOutput"
Write-Host ''

$OutputInput = Read-Host 'Press ENTER to accept the default, or type a custom output folder path'
if ([string]::IsNullOrWhiteSpace($OutputInput)) {
    $OutputFolder = $DefaultOutput
} else {
    $OutputFolder = $OutputInput.Trim('"')
}

Write-Host ''
Write-Host 'Collection folder:'
Write-Host "  $CollectionPath"
Write-Host 'Output folder:'
Write-Host "  $OutputFolder"
Write-Host ''

$Confirm = Read-Host 'Type Y to proceed with extraction, or any other key to cancel'
if ($Confirm -ne 'Y' -and $Confirm -ne 'y') {
    Write-Host ''
    Write-Host 'Extraction cancelled.'
    Read-Host 'Press ENTER to close'
    return
}

# Ensure output folder exists
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

# Progress bar setup
$Total = $WarcGz.Count
$Success = 0
$Failed  = 0

Write-Host ''
Write-Host '========================================='
Write-Host "Starting extraction of $Total WARC file(s)..."
Write-Host '========================================='
Write-Host ''

$Index = 0

foreach ($file in $WarcGz) {
    $Index++
    $percent = [int](($Index / $Total) * 100)
    $status  = "Extracting $Index of $Total"
    $name    = $file.Name

    # Update progress bar
    Write-Progress -Activity 'Extracting WARCs' -Status "$status - $name" -PercentComplete $percent

    Write-Host "[$Index/$Total] Extracting: $name"

    # Call Python for this single file
    python "$PythonScript" "$($file.FullName)" -o "$OutputFolder"
    $ExitCode = $LASTEXITCODE

    if ($ExitCode -eq 0) {
        $Success++
    } else {
        $Failed++
        Write-Host "  ERROR: Python returned exit code $ExitCode for file:" -ForegroundColor Red
        Write-Host "         $($file.FullName)"
    }

    Write-Host ''
}

# Complete the progress bar
Write-Progress -Activity 'Extracting WARCs' -Completed

Write-Host '========================================='
Write-Host 'Extraction finished.'
Write-Host "  Total files:      $Total"
Write-Host "  Successfully extracted: $Success"
Write-Host "  Failed:           $Failed"
Write-Host '========================================='
Write-Host ''

if ($Failed -eq 0) {
    Write-Host 'All files extracted successfully.'
} else {
    Write-Host 'Some files failed to extract. Review messages above.'
}

Write-Host ''
Read-Host 'Press ENTER to close'
