# Keep errors visible so we can see what went wrong
$ErrorActionPreference = "Stop"

<#
.SYNOPSIS
    Interactive Archive-It WARC checker + auto redownloader.

.DESCRIPTION
    Prompts for:
      - Collection ID
      - Username
      - Password (secure/hidden)
      - WARC folder path
      - Output folder for manifest + report

    Does the following:
      1. Downloads Archive-It WASAPI manifest (with pagination)
         from: https://warcs.archive-it.org/wasapi/v1/webdata?collection=ID&format=json
      2. Builds a list of expected filenames.
      3. Scans the WARC folder for *.warc / *.warc.gz files.
      4. Identifies:
           - Missing files (in manifest, not on disk)
           - Zero-byte files (treated as partial/corrupt)
           - Temp/incomplete extension files (.open, .part, .tmp) [reported only]
      5. Automatically:
           - Downloads any missing WARCs.
           - Deletes and re-downloads any zero-byte WARCs.
      6. Writes a text report you can re-run as often as you like.
#>

function Write-ReportLine {
    param([string]$Text)
    Write-Host $Text
    if ($script:ReportPath) {
        Add-Content -Path $script:ReportPath -Value $Text
    }
}

try {
    Write-Host ""
    Write-Host "===== Archive-It WARC Download Checker & Fixer ====="
    Write-Host ""

    # -------- Prompt for core info --------
    $CollectionID = Read-Host "Enter Archive-It Collection ID"
    $Username     = Read-Host "Enter Archive-It username"
    $SecurePassword = Read-Host "Enter Archive-It password" -AsSecureString

    $WarcFolderInput   = Read-Host "Enter the FULL path to your WARC folder"
    $ReportFolderInput = Read-Host "Enter the FULL path where reports should be saved"

    # -------- Resolve paths --------
    $WarcFolder   = (Resolve-Path $WarcFolderInput).Path
    $OutputFolder = (Resolve-Path $ReportFolderInput).Path

    $script:ReportPath = Join-Path $OutputFolder "WarcDownloadReport.txt"
    $ManifestPath      = Join-Path $OutputFolder "wasapi_manifest.json"

    # -------- Convert secure password -> Basic Auth header --------
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    try {
        $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }

    $authPair  = "$Username`:$PlainPassword"
    $authBytes = [System.Text.Encoding]::UTF8.GetBytes($authPair)
    $authToken = [System.Convert]::ToBase64String($authBytes)

    # Immediately clear plaintext password for safety
    $PlainPassword = $null

    $Headers = @{
        "Accept"        = "application/json"
        "Authorization" = "Basic $authToken"
    }

    # -------- WASAPI URL (correct endpoint) --------
    $baseUrl   = "https://warcs.archive-it.org/wasapi/v1/webdata?collection=$CollectionID&format=json"
    $pageUrl   = $baseUrl
    $pageIndex = 1
    $allFiles  = @()

    Write-Host ""
    Write-Host "Fetching WASAPI manifest for collection $CollectionID..."
    Write-Host "Start URL: $baseUrl"
    Write-Host ""

    # -------- Pagination loop --------
    while ($true) {
        Write-Host "Requesting page $pageIndex ..."
        $response = Invoke-WebRequest -Uri $pageUrl -Headers $Headers -UseBasicParsing
        $content  = $response.Content

        # If we get HTML instead of JSON, it's probably a login page or error
        if ($content -match "<html" -or $content -match "<!DOCTYPE html") {
            $errFile = Join-Path $OutputFolder "wasapi_error_page.html"
            $content | Out-File -FilePath $errFile -Encoding UTF8
            throw "Archive-It returned HTML instead of JSON (likely auth or access issue). Saved to: $errFile"
        }

        $json = $content | ConvertFrom-Json

        if ($json.files) {
            $allFiles += $json.files
        }

        if ($json.next) {
            $pageUrl = $json.next
            $pageIndex++
        } else {
            break
        }
    }

    Write-Host ""
    Write-Host "Total WARC entries in manifest: $($allFiles.Count)"
    $allFiles | ConvertTo-Json -Depth 5 | Out-File -FilePath $ManifestPath -Encoding UTF8
    Write-Host "Combined manifest saved to: $ManifestPath"
    Write-Host ""

    # -------- Build mapping: filename -> manifest entry --------
    $expectedNames  = @()
    $manifestByName = @{}

    foreach ($file in $allFiles) {
        $name = $null

        if ($file.filename) {
            $name = $file.filename
        }
        elseif ($file.locations) {
            foreach ($loc in $file.locations) {
                if ($loc -match "https?://") {
                    $uri  = [Uri]$loc
                    $name = [System.IO.Path]::GetFileName($uri.AbsolutePath)
                    if ($name) { break }
                }
            }
        }

        if ($name) {
            $expectedNames += $name
            if (-not $manifestByName.ContainsKey($name)) {
                $manifestByName[$name] = $file
            }
        }
    }

    $expectedNames = $expectedNames | Sort-Object -Unique

    # -------- Scan local WARC folder --------
    Write-Host "Scanning local WARC folder: $WarcFolder"

    $localWarcFiles = Get-ChildItem -Path $WarcFolder -Recurse -File -Include *.warc, *.warc.gz
    $allLocalFiles  = Get-ChildItem -Path $WarcFolder -Recurse -File

    $localByName = @{}
    foreach ($f in $localWarcFiles) {
        $localByName[$f.Name] = $f
    }

    # -------- Identify missing and zero-byte partials --------
    $missing = $expectedNames | Where-Object { -not $localByName.ContainsKey($_) }

    # Partial = EXACTLY 0 bytes
    $partialFiles = $localWarcFiles | Where-Object { $_.Length -eq 0 }

    # Weird temp extensions (.open/.part/.tmp) — we just report these
    $weirdExts  = ".open", ".part", ".tmp"
    $weirdFiles = $allLocalFiles |
        Where-Object { $weirdExts -contains $_.Extension.ToLowerInvariant() }

    # -------- Write main report header --------
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content -Path $ReportPath -Value ""
    Add-Content -Path $ReportPath -Value "==========================================="
    Add-Content -Path $ReportPath -Value "ARCHIVE-IT WARC DOWNLOAD REPORT - $timestamp"
    Add-Content -Path $ReportPath -Value "Collection:       $CollectionID"
    Add-Content -Path $ReportPath -Value "Expected files:   $($expectedNames.Count)"
    Add-Content -Path $ReportPath -Value "Local WARC files: $($localWarcFiles.Count)"
    Add-Content -Path $ReportPath -Value ""

    Write-Host ""
    Write-Host "===== REPORT WRITTEN TO ====="
    Write-Host "  $ReportPath"
    Write-Host ""

    # Missing
    if ($missing.Count -gt 0) {
        Write-ReportLine "MISSING FILES (in manifest but not in folder):"
        $missing | ForEach-Object { Write-ReportLine "  $_" }
        Write-ReportLine ""
    } else {
        Write-ReportLine "No missing files."
        Write-ReportLine ""
    }

    # Zero-byte partials
    if ($partialFiles.Count -gt 0) {
        Write-ReportLine "ZERO-BYTE / PARTIAL FILES:"
        foreach ($f in $partialFiles) {
            Write-ReportLine "  $($f.FullName)  (0 bytes)"
        }
        Write-ReportLine ""
    } else {
        Write-ReportLine "No zero-byte partial files."
        Write-ReportLine ""
    }

    # Weird temp/incomplete files
    if ($weirdFiles.Count -gt 0) {
        Write-ReportLine "TEMP/INCOMPLETE EXTENSION FILES (.open / .part / .tmp):"
        foreach ($wf in $weirdFiles) {
            Write-ReportLine "  $($wf.FullName)"
        }
        Write-ReportLine ""
    } else {
        Write-ReportLine "No temporary-extension files."
        Write-ReportLine ""
    }

    # -------- AUTO-DOWNLOAD SECTION --------
    Write-ReportLine "-------------------------------------------"
    Write-ReportLine "AUTO-DOWNLOAD / REDOWNLOAD ACTIONS"
    Write-ReportLine "-------------------------------------------"

    # Build list of filenames that need download/redownload
    $toRedownloadNames = @()
    $toRedownloadNames += $missing
    $toRedownloadNames += ($partialFiles | ForEach-Object { $_.Name })
    $toRedownloadNames = $toRedownloadNames | Sort-Object -Unique

    if ($toRedownloadNames.Count -eq 0) {
        Write-ReportLine "No files need to be downloaded or redownloaded."
    }
    else {
        foreach ($name in $toRedownloadNames) {
            Write-Host ""
            Write-Host "Processing $name ..."
            Write-ReportLine ""
            Write-ReportLine "Processing $name ..."

            if (-not $manifestByName.ContainsKey($name)) {
                Write-ReportLine "  SKIP: No matching entry in manifest for $name."
                continue
            }

            $fileEntry = $manifestByName[$name]

            # Pick a download URL from locations (prefer primary warcs.archive-it.org)
            $downloadUrl = $null
            if ($fileEntry.locations) {
                $primary = $fileEntry.locations |
                    Where-Object { $_ -like "https://warcs.archive-it.org/webdatafile/*" } |
                    Select-Object -First 1

                if ($primary) {
                    $downloadUrl = $primary
                } else {
                    $downloadUrl = $fileEntry.locations[0]
                }
            }

            if (-not $downloadUrl) {
                Write-ReportLine "  ERROR: No download URL found in manifest for $name."
                continue
            }

            $destPath = Join-Path $WarcFolder $name

            # If an existing (partial) file is there, delete it first
            if (Test-Path -Path $destPath) {
                try {
                    Remove-Item -Path $destPath -Force
                    Write-ReportLine "  Deleted existing file: $destPath"
                }
                catch {
                    Write-ReportLine "  ERROR: Could not delete existing file: $destPath"
                    Write-ReportLine "         $_"
                    continue
                }
            }

            Write-Host "  Downloading from: $downloadUrl"
            Write-ReportLine "  Downloading from: $downloadUrl"

            try {
                Invoke-WebRequest -Uri $downloadUrl -Headers $Headers -OutFile $destPath -UseBasicParsing

                # Check final size
                $newFile = Get-Item -Path $destPath
                $sizeMB  = [Math]::Round($newFile.Length / 1MB, 2)
                Write-ReportLine "  SUCCESS: Downloaded to $destPath ($sizeMB MB)"
            }
            catch {
                Write-ReportLine "  ERROR: Failed to download $name"
                Write-ReportLine "         $_"

                # If download failed, remove any zero-byte file left behind
                if (Test-Path -Path $destPath) {
                    $f = Get-Item -Path $destPath
                    if ($f.Length -eq 0) {
                        Remove-Item -Path $destPath -Force
                    }
                }
            }
        }
    }

    Write-Host ""
    Write-Host "Check + auto-fix complete."
    Write-Host "See report for details:"
    Write-Host "  $ReportPath"
}
catch {
    Write-Host ""
    Write-Host "FATAL ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message

    if ($script:ReportPath) {
        Add-Content -Path $script:ReportPath -Value ""
        Add-Content -Path $script:ReportPath -Value "ERROR at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $($_.Exception.Message)"
    }
}
finally {
    Write-Host ""
    Read-Host "Press Enter to close this window"
}
