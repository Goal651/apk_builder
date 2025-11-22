# ========== UTILITY FUNCTIONS ========== #

function Show-Version {
    Write-Host "Wilson Goal's AAB Converter v$script:VERSION"
    Write-Host "Bundletool version: $script:BUNDLETOOL_VERSION"
    Write-Host "Optimized for Windows 10/11 PowerShell"
}

function Test-Dependencies {
    Write-Host ""
    Write-Host "=[ SYSTEM ANALYSIS ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Dependency Check ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    $missingDeps = @()
    $installCommands = @()
    
    # Check Java
    Write-Host "[*] Analyzing Java Development Kit... " -NoNewline
    Start-Sleep -Milliseconds 500
    
    try {
        $javaVersion = & java -version 2>&1 | Select-Object -First 1
        if ($javaVersion -match 'version "([^"]+)"') {
            $version = $matches[1]
            Write-Host "FOUND ($version)" -ForegroundColor $COLOR_GREEN
        }
        else {
            throw "Java not found"
        }
    }
    catch {
        Write-Host "NOT FOUND" -ForegroundColor $COLOR_RED
        $missingDeps += "Java Development Kit (JDK 8+)"
        $installCommands += "Download from https://adoptium.net/ or https://www.oracle.com/java/technologies/downloads/"
    }
    
    # Check curl (PowerShell has Invoke-WebRequest, so this is informational)
    Write-Host "[*] Analyzing web request capability... " -NoNewline
    Start-Sleep -Milliseconds 300
    
    if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
        Write-Host "FOUND (Invoke-WebRequest)" -ForegroundColor $COLOR_GREEN
    }
    else {
        Write-Host "NOT FOUND" -ForegroundColor $COLOR_RED
        $missingDeps += "PowerShell 3.0+"
        $installCommands += "Update PowerShell from https://github.com/PowerShell/PowerShell"
    }
    
    # Check bundletool
    Write-Host "[*] Analyzing Bundletool... " -NoNewline
    Start-Sleep -Milliseconds 200
    
    $bundletoolFound = $null
    $searchPaths = @(".", $env:USERPROFILE, "$env:USERPROFILE\.local\bin")
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $bundletoolFound = Get-ChildItem -Path $path -Filter "bundletool*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($bundletoolFound) { break }
        }
    }
    
    if (-not $bundletoolFound) {
        Write-Host "NOT FOUND" -ForegroundColor $COLOR_RED
        $missingDeps += "Bundletool $script:BUNDLETOOL_VERSION"
        $installCommands += "download_bundletool"
    }
    else {
        Write-Host "FOUND ($($bundletoolFound.Name))" -ForegroundColor $COLOR_GREEN
    }
    
    Write-Host ""
    
    # If no missing dependencies, return success
    if ($missingDeps.Count -eq 0) {
        Log-Success "System analysis complete - All dependencies satisfied!"
        Log-Success "Ready for AAB conversion operations."
        Write-Host ""
        return $true
    }
    
    # Show missing dependencies
    Write-Host "=[ DEPENDENCY ISSUES DETECTED ]=" -ForegroundColor $COLOR_RED
    Write-Host ""
    foreach ($dep in $missingDeps) {
        Write-Host "  [-] $dep" -ForegroundColor $COLOR_RED
    }
    Write-Host ""
    
    # Show installation plan
    Write-Host "=[ INSTALLATION PLAN ]=" -ForegroundColor $COLOR_BLUE
    Write-Host ""
    for ($i = 0; $i -lt $missingDeps.Count; $i++) {
        $dep = $missingDeps[$i]
        $cmd = $installCommands[$i]
        
        if ($cmd -eq "download_bundletool") {
            Write-Host "  [*] Download Bundletool $script:BUNDLETOOL_VERSION from GitHub" -ForegroundColor $COLOR_CYAN
        }
        else {
            Write-Host "  [*] $cmd" -ForegroundColor $COLOR_CYAN
        }
    }
    Write-Host ""
    
    # Ask for confirmation
    if ($script:INTERACTIVE) {
        Write-Host "🤔 Would you like me to automatically install/download these missing dependencies? [y/N]: " -ForegroundColor $COLOR_YELLOW -NoNewline
        $response = Read-Host
        
        if ($response -match '^[yY]') {
            Log-Info "🔧 Installing missing dependencies..."
            Write-Host ""
            
            for ($i = 0; $i -lt $missingDeps.Count; $i++) {
                $dep = $missingDeps[$i]
                $cmd = $installCommands[$i]
                
                Write-Host "➤ Processing: $dep" -ForegroundColor $COLOR_BLUE
                
                if ($cmd -eq "download_bundletool") {
                    if (-not (Install-BundleTool)) {
                        Log-Error "Failed to install $dep"
                        exit 1
                    }
                }
                else {
                    Log-Warning "Please install manually: $cmd"
                }
                Write-Host ""
            }
            
            Log-Success "🎉 All automatic installations completed!"
        }
        else {
            Log-Error "❌ Cannot proceed without required dependencies"
            Log-Error "💡 Please install them manually and run the script again"
            exit 1
        }
    }
    else {
        Log-Error "❌ Missing dependencies detected in non-interactive mode"
        Log-Error "💡 Please install manually: $($missingDeps -join ', ')"
        exit 1
    }
}

function Invoke-Cleanup {
    Write-Host ""
    Write-Host "=[ CLEANUP MODE ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Remove Generated Files ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Log-Info "Scanning for files to clean..."
    
    $filesToClean = @()
    $totalSize = 0
    
    # Find bundletool files
    $bundletoolFiles = Get-ChildItem -Path "." -Filter "bundletool*.jar" -ErrorAction SilentlyContinue
    foreach ($file in $bundletoolFiles) {
        $filesToClean += $file
        $totalSize += $file.Length
    }
    
    # Find keystore files
    $keystoreFiles = Get-ChildItem -Path "." -Filter "*.keystore" -ErrorAction SilentlyContinue
    foreach ($file in $keystoreFiles) {
        $filesToClean += $file
        $totalSize += $file.Length
    }
    
    # Find generated APK files
    $apkFiles = Get-ChildItem -Path "." -Filter "*.apks" -ErrorAction SilentlyContinue
    foreach ($file in $apkFiles) {
        $filesToClean += $file
        $totalSize += $file.Length
    }
    
    if ($filesToClean.Count -eq 0) {
        Log-Info "No files found to clean"
        return
    }
    
    Write-Host "[!] Files to be removed:" -ForegroundColor $COLOR_YELLOW
    foreach ($file in $filesToClean) {
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        Write-Host "  [-] $($file.Name) ($sizeMB MB)"
    }
    Write-Host ""
    
    $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
    Write-Host "[!] Total space to be freed: $totalSizeMB MB" -ForegroundColor $COLOR_YELLOW
    Write-Host ""
    
    if ($script:INTERACTIVE) {
        $confirm = Read-Host "[?] Are you sure you want to remove these files? [y/N]"
        if ($confirm -notmatch '^[yY]') {
            Log-Info "Cleanup cancelled"
            return
        }
    }
    
    $removed = 0
    foreach ($file in $filesToClean) {
        try {
            Remove-Item -Path $file.FullName -Force
            Log-Success "Removed: $($file.Name)"
            $removed++
        }
        catch {
            Log-Error "Failed to remove: $($file.Name)"
        }
    }
    
    Log-Success "Cleanup complete: $removed file(s) removed"
    Log-Info "Space freed: $totalSizeMB MB"
}
