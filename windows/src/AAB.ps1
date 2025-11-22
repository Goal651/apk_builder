# ========== AAB OPERATIONS ========== #

function Test-AAB {
    param(
        [string]$AABFile,
        [string]$BundleToolPath
    )
    
    Log-Info "🔍 Validating: $AABFile"
    
    # Check if file exists first
    if (-not (Test-Path $AABFile)) {
        Log-Error "❌ File not found: $AABFile"
        return $false
    }
    
    # Validate with bundletool and capture output
    try {
        $output = & java -jar $BundleToolPath validate --bundle=$AABFile 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Log-Error "❌ Validation failed for $AABFile"
            Write-Host $output -ForegroundColor $COLOR_RED
            return $false
        }
        
        Log-Success "✅ Valid AAB: $AABFile"
        Write-Host $output -ForegroundColor $COLOR_GREEN
        return $true
    }
    catch {
        Log-Error "❌ Validation failed for $AABFile"
        Write-Host $_ -ForegroundColor $COLOR_RED
        return $false
    }
}

function Get-AABInfo {
    param(
        [string]$AABFile,
        [string]$BundleToolPath
    )
    
    Log-Info "📋 Bundle info: $AABFile"
    
    # Check if file exists first
    if (-not (Test-Path $AABFile)) {
        Log-Error "❌ File not found: $AABFile"
        return $false
    }
    
    # Get manifest info and handle errors
    try {
        $output = & java -jar $BundleToolPath dump manifest --bundle=$AABFile 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Log-Error "❌ Failed to get manifest info for $AABFile"
            Write-Host $output -ForegroundColor $COLOR_RED
            return $false
        }
        
        $output | Select-Object -First 20 | ForEach-Object {
            Write-Host $_ -ForegroundColor $COLOR_CYAN
        }
        return $true
    }
    catch {
        Log-Error "❌ Failed to get manifest info for $AABFile"
        Write-Host $_ -ForegroundColor $COLOR_RED
        return $false
    }
}

function Convert-AAB {
    param(
        [string]$AABFile,
        [string]$BundleToolPath
    )
    
    Log-Info "📦 Processing: $AABFile"
    
    # Check if file exists first
    if (-not (Test-Path $AABFile)) {
        Log-Error "❌ File not found: $AABFile"
        return $false
    }
    
    $fileSize = (Get-Item $AABFile).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Log-Debug "File size: $fileSizeMB MB"
    
    $appName = ""
    if ($script:INTERACTIVE) {
        Write-Host ""
        Write-Host "=[ APP CONFIGURATION ]=" -ForegroundColor $COLOR_GREEN
        Write-Host "+ --- --=[ Output Settings ]=-- --- +" -ForegroundColor $COLOR_GREEN
        Write-Host ""
        
        while ($true) {
            $appName = Read-Host "[?] Enter output app name (no spaces/special chars)"
            
            if ([string]::IsNullOrWhiteSpace($appName)) {
                Log-Warning "App name cannot be empty"
            }
            elseif ($appName -notmatch '^[a-zA-Z0-9_-]+$') {
                Log-Warning "Invalid characters. Use only letters, numbers, underscores or hyphens"
            }
            else {
                Log-Info "Output name set to: $appName"
                break
            }
        }
    }
    else {
        $appName = [System.IO.Path]::GetFileNameWithoutExtension($AABFile)
    }
    
    $outputName = Join-Path $script:OUTPUT_DIR "$appName.apks"
    
    # Ensure keystore exists
    if (-not (New-Keystore -KeystorePath $script:KEYSTORE_PATH -KeystoreAlias $script:KEYSTORE_ALIAS -KeystorePassword $script:KEYSTORE_PASS)) {
        return $false
    }
    
    Log-Info "Converting AAB to APKS format..."
    
    # Create output directory if needed
    if ($script:OUTPUT_DIR -ne "." -and -not (Test-Path $script:OUTPUT_DIR)) {
        try {
            New-Item -ItemType Directory -Path $script:OUTPUT_DIR -Force | Out-Null
        }
        catch {
            Log-Error "Failed to create output directory: $script:OUTPUT_DIR"
            return $false
        }
    }
    
    Write-Host "[*] Processing bundle... " -NoNewline
    
    # Convert with bundletool and capture output
    try {
        $javaArgs = @(
            "-jar", $BundleToolPath,
            "build-apks",
            "--bundle=$AABFile",
            "--output=$outputName",
            "--mode=$($script:BUILD_MODE)",
            "--ks=$($script:KEYSTORE_PATH)",
            "--ks-key-alias=$($script:KEYSTORE_ALIAS)",
            "--ks-pass=pass:$($script:KEYSTORE_PASS)",
            "--key-pass=pass:$($script:KEYSTORE_PASS)"
        )
        
        $output = & java $javaArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "FAILED" -ForegroundColor $COLOR_RED
            Log-Error "Conversion failed for $AABFile"
            Write-Host $output -ForegroundColor $COLOR_RED
            return $false
        }
        
        Write-Host "DONE" -ForegroundColor $COLOR_GREEN
        Log-Success "Created: $outputName"
        
        $outputSize = (Get-Item $outputName).Length
        $outputSizeMB = [math]::Round($outputSize / 1MB, 2)
        Log-Debug "Output size: $outputSizeMB MB"
        return $true
    }
    catch {
        Write-Host "FAILED" -ForegroundColor $COLOR_RED
        Log-Error "Conversion failed for $AABFile"
        Write-Host $_ -ForegroundColor $COLOR_RED
        return $false
    }
}

function Invoke-Convert {
    $bundletoolPath = Get-BundleTool
    Log-Info "🔍 Found bundletool at: $bundletoolPath"
    
    Log-Info "🔍 Checking AAB files..."
    $aabFiles = Get-ChildItem -Path "." -Filter "*.aab" -File
    
    if ($aabFiles.Count -eq 0) {
        Log-Error "🚫 No AAB files found in current directory"
        Log-Error "💡 Please place .aab files in $(Get-Location) and try again"
        exit 1
    }
    
    Log-Info "📁 Found $($aabFiles.Count) AAB file(s):"
    if ($aabFiles.Count -gt 0) {
        Write-Host ""
        $aabFiles | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            Write-Host "  $($_.Name) ($sizeMB MB)" -ForegroundColor $COLOR_BLUE
        }
        Write-Host ""
    }
    
    $failedCount = 0
    foreach ($aabFile in $aabFiles) {
        if (-not (Convert-AAB -AABFile $aabFile.FullName -BundleToolPath $bundletoolPath)) {
            $failedCount++
        }
    }
    
    if ($failedCount -eq 0) {
        Log-Success "🎊 All conversions completed successfully!"
    }
    else {
        Log-Warning "⚠️  Completed with $failedCount error(s)"
        exit 1
    }
}

function Invoke-Validate {
    $bundletoolPath = Get-BundleTool
    Log-Info "🔍 Found bundletool at: $bundletoolPath"
    
    Log-Info "🔍 Checking AAB files for validation..."
    $aabFiles = Get-ChildItem -Path "." -Filter "*.aab" -File
    
    if ($aabFiles.Count -eq 0) {
        Log-Error "🚫 No AAB files found in current directory"
        Log-Error "💡 Please place .aab files in $(Get-Location) and try again"
        exit 1
    }
    
    $failedCount = 0
    foreach ($aabFile in $aabFiles) {
        if (-not (Test-AAB -AABFile $aabFile.FullName -BundleToolPath $bundletoolPath)) {
            $failedCount++
        }
    }
    
    if ($failedCount -eq 0) {
        Log-Success "✅ Validation completed - All files valid!"
    }
    else {
        Log-Warning "⚠️  Validation completed with $failedCount invalid file(s)"
        exit 1
    }
}

function Invoke-Info {
    $bundletoolPath = Get-BundleTool
    Log-Info "🔍 Found bundletool at: $bundletoolPath"
    
    Log-Info "📋 Showing AAB information..."
    $aabFiles = Get-ChildItem -Path "." -Filter "*.aab" -File
    
    if ($aabFiles.Count -eq 0) {
        Log-Error "🚫 No AAB files found in current directory"
        Log-Error "💡 Please place .aab files in $(Get-Location) and try again"
        exit 1
    }
    
    $failedCount = 0
    foreach ($aabFile in $aabFiles) {
        Write-Host "═══════════════════════════════════════" -ForegroundColor $COLOR_CYAN
        if (-not (Get-AABInfo -AABFile $aabFile.FullName -BundleToolPath $bundletoolPath)) {
            $failedCount++
        }
        Write-Host ""
    }
    
    if ($failedCount -eq 0) {
        Log-Success "✅ Information displayed for all files"
    }
    else {
        Log-Warning "⚠️  Could not get info for $failedCount file(s)"
        exit 1
    }
}

function Invoke-Batch {
    Write-Host ""
    Write-Host "=[ BATCH PROCESSING MODE ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Queue Management ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    $bundletoolPath = Get-BundleTool
    Log-Info "Found bundletool at: $bundletoolPath"
    
    Log-Info "Scanning for AAB files..."
    $aabFiles = Get-ChildItem -Path "." -Filter "*.aab" -File
    
    if ($aabFiles.Count -eq 0) {
        Log-Error "No AAB files found in current directory"
        Log-Error "Place .aab files in $(Get-Location) and try again"
        exit 1
    }
    
    Log-Info "Found $($aabFiles.Count) file(s) in queue"
    
    $processed = 0
    $successful = 0
    $failed = 0
    $startTime = Get-Date
    
    foreach ($aabFile in $aabFiles) {
        $processed++
        
        Log-Info "Processing [$processed/$($aabFiles.Count)]: $($aabFile.Name)"
        
        if (Convert-AAB -AABFile $aabFile.FullName -BundleToolPath $bundletoolPath) {
            $successful++
            Log-Success "Completed: $($aabFile.Name)"
        }
        else {
            $failed++
            Log-Error "Failed: $($aabFile.Name)"
        }
        
        # Show progress
        $percentage = [math]::Round(($processed / $aabFiles.Count) * 100)
        Write-Host "[*] Progress: $processed/$($aabFiles.Count) files ($percentage%)" -ForegroundColor $COLOR_BLUE
        Write-Host ""
    }
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host ""
    Write-Host "=[ BATCH PROCESSING COMPLETE ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Statistics ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    Log-Info "Total files processed: $processed"
    Log-Success "Successful conversions: $successful"
    if ($failed -gt 0) {
        Log-Warning "Failed conversions: $failed"
    }
    Log-Info "Total time: $([math]::Round($duration, 2))s"
    Log-Info "Average time per file: $([math]::Round($duration / $processed, 2))s"
}
