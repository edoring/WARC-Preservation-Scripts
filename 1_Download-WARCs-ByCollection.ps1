# ==========================================
# Download-WARCs-ByCollection.ps1
# Interactive WARC downloader (collection level)
# - Prompts for Collection ID + username + password
# - Paginates over WASAPI results (?collection= & page=)
# - Saves all WARCs into Tools\WARCs\Collection-<ID>\
# - DOES NOT decompress or modify .warc.gz files
# - Logs everything with timestamps
# ==========================================

# -------- Prompt for values --------

$CollectionId = Read-Host "Enter the Collection ID (example: 2093)"
$Username     = Read-Host "Enter your Archive-It username (example: edoring)"
$securePwd    = Read-Host "Enter your Archive-It password" -AsSecureString

# Convert SecureString → plain text (only in memory during this run)
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd)
try {
    $plainPwd = [Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

# -------- Setup paths --------

if (-not $PSScriptRoot) {
    $PSScriptRoot = (Get-Location).Path
}

$RootWarcDir = Join-Path $PSScriptRoot "WARCs"
$OutputDir   = Join-Path $RootWarcDir "Collection-$CollectionId"

if (-not (Test-Path $RootWarcDir)) { New-Item -ItemType Directory -Path $RootWarcDir | Out-Null }
if (-not (Test-Path $OutputDir))   { New-Item -ItemType Directory -Path $OutputDir   | Out-Null }

$jqPath   = Join-Path $PSScriptRoot "jq.exe"
$wgetPath = Join-Path $PSScriptRoot "wget.exe"

$LogFile = Join-Path $OutputDir "Download-WARCs-Collection-$CollectionId-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# -------- Logger --------

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

# -------- Start Script --------

Write-Log "Starting WARC download for Collection ID $CollectionId"
Write-Log "Saving all output to: $OutputDir"

if (-not (Test-Path $jqPath)) {
    Write-Log "ERROR: jq.exe not found in $PSScriptRoot" "ERROR"
    throw "jq.exe missing"
}

if (-not (Test-Path $wgetPath)) {
    Write-Log "ERROR: wget.exe not found in $PSScriptRoot" "ERROR"
    throw "wget.exe missing"
}

# -------- Build base WASAPI URL (collection-level) --------

$baseUrl = "https://warcs.archive-it.org/wasapi/v1/webdata?collection=$CollectionId"
Write-Log "Base WASAPI URL: $baseUrl"

# -------- Fetch WARC URLs with pagination --------

$warcListFile = Join-Path $OutputDir "warc_urls-Collection-$CollectionId.txt"

# Ensure we start fresh and with proper encoding
"" | Out-File -FilePath $warcListFile -Encoding ascii

$page   = 1
$total  = 0

Write-Log "Beginning pagination over collection $CollectionId."

while ($true) {
    $pageUrl = "$baseUrl&page=$page"
    Write-Log ("Requesting page {0}: {1}" -f $page, $pageUrl)

    try {
        # Get URLs for this page
        $batchUrls = curl.exe -s -u "$Username`:$plainPwd" $pageUrl | & $jqPath -r ".files[].locations[0]"
    }
    catch {
        Write-Log ("ERROR: Failed to query WASAPI on page {0}: {1}" -f $page, $_) "ERROR"
        throw
    }

    if (-not $batchUrls) {
        Write-Log "Page returned 0 files. Stopping pagination."
        break
    }

    $batchArray = @($batchUrls)
    $count = $batchArray.Count

    $batchArray | Out-File -FilePath $warcListFile -Encoding ascii -Append

    $total += $count
    Write-Log ("Page {0}: found {1} file(s). Running total: {2}." -f $page, $count, $total)

    $page++
}

if ($total -eq 0) {
    Write-Log "No WARC files were found for collection $CollectionId. Check Collection ID or permissions." "ERROR"
    throw "No WARC URLs found."
}

Write-Log "Finished pagination. Total WARC files discovered: $total."

# -------- Download WARCs --------

Write-Log "Starting download of all WARCs with wget."

$startTime = Get-Date

Push-Location $OutputDir
& $wgetPath --http-user=$Username --http-password=$plainPwd -i $warcListFile
$exitCode = $LASTEXITCODE
Pop-Location

$endTime  = Get-Date
$duration = $endTime - $startTime

Write-Log "wget exit code: $exitCode"
Write-Log "Download started: $startTime"
Write-Log "Download ended:   $endTime"
Write-Log "Duration:          $duration"

if ($exitCode -ne 0) {
    Write-Log "WARNING: wget reported errors. Some files may have failed." "WARN"
} else {
    Write-Log "Download completed successfully!" "INFO"
}

Write-Log "Script finished for collection $CollectionId."


