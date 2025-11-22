# ========== BUNDLETOOL MANAGEMENT ========== #

function Test-BundleToolUpdate {
    Log-Info "Checking for bundletool updates..."
    
    try {
        # Get latest version from GitHub API
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/google/bundletool/releases/latest"
        $latestVersion = $response.tag_name -replace '^v', ''
        
        if ($latestVersion -ne $script:BUNDLETOOL_VERSION) {
            Log-Info "New bundletool version available: $latestVersion (current: $script:BUNDLETOOL_VERSION)"
            
            if ($script:INTERACTIVE) {
                $updateChoice = Read-Host "[?] Would you like to update bundletool? [y/N]"
                if ($updateChoice -match '^[yY]') {
                    Update-BundleTool -NewVersion $latestVersion
                }
                else {
                    Log-Info "Update cancelled"
                }
            }
            else {
                Log-Info "Run with -Interactive to update bundletool"
            }
        }
        else {
            Log-Success "Bundletool is up to date ($script:BUNDLETOOL_VERSION)"
        }
    }
    catch {
        Log-Warning "Could not check for updates: $_"
        return $false
    }
}

function Update-BundleTool {
    param([string]$NewVersion)
    
    Log-Info "Updating bundletool to version $NewVersion..."
    
    # Backup current version
    if (Test-Path $script:DEFAULT_BUNDLETOOL) {
        Move-Item -Path $script:DEFAULT_BUNDLETOOL -Destination "$($script:DEFAULT_BUNDLETOOL).backup" -Force
        Log-Info "Backed up current version"
    }
    
    # Update constants for new version
    $script:BUNDLETOOL_VERSION = $NewVersion
    $script:BUNDLETOOL_URL = "https://github.com/google/bundletool/releases/download/$NewVersion/bundletool-all-$NewVersion.jar"
    $script:DEFAULT_BUNDLETOOL = ".\bundletool-all-$NewVersion.jar"
    
    # Download new version
    if (Install-BundleTool) {
        Log-Success "Bundletool updated successfully to $NewVersion"
        
        # Remove backup
        if (Test-Path "$($script:DEFAULT_BUNDLETOOL).backup") {
            Remove-Item -Path "$($script:DEFAULT_BUNDLETOOL).backup" -Force
            Log-Info "Removed backup file"
        }
        
        # Update config with new version
        Save-Config
    }
    else {
        Log-Error "Failed to update bundletool"
        # Restore backup
        if (Test-Path "$($script:DEFAULT_BUNDLETOOL).backup") {
            Move-Item -Path "$($script:DEFAULT_BUNDLETOOL).backup" -Destination $script:DEFAULT_BUNDLETOOL -Force
            Log-Info "Restored backup version"
        }
        return $false
    }
}

function Install-BundleTool {
    Log-Info "Downloading bundletool $script:BUNDLETOOL_VERSION..."
    
    Write-Host "[*] Downloading... " -NoNewline
    
    try {
        Invoke-WebRequest -Uri $script:BUNDLETOOL_URL -OutFile $script:DEFAULT_BUNDLETOOL -UseBasicParsing
        
        $fileSize = (Get-Item $script:DEFAULT_BUNDLETOOL).Length
        $fileSizeMB = [math]::Round($fileSize / 1MB, 1)
        
        Write-Host "DONE" -ForegroundColor $COLOR_GREEN
        Log-Success "Download completed ($fileSizeMB MB)"
        Log-Debug "Location: $(Get-Location)\$script:DEFAULT_BUNDLETOOL"
        return $true
    }
    catch {
        Write-Host "FAILED" -ForegroundColor $COLOR_RED
        Log-Error "Failed to download bundletool!"
        Log-Error "URL: $script:BUNDLETOOL_URL"
        Log-Error "Error: $_"
        return $false
    }
}

function Get-BundleTool {
    # Search common locations for bundletool
    $searchPaths = @(
        ".",
        $env:USERPROFILE,
        "$env:USERPROFILE\.local\bin",
        "$env:ProgramFiles\bundletool",
        "$env:ProgramFiles(x86)\bundletool"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $found = Get-ChildItem -Path $path -Filter "bundletool*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) {
                return $found.FullName
            }
        }
    }
    
    Log-Warning "🔍 Bundletool not found in common locations, downloading..."
    Install-BundleTool | Out-Null
    return (Resolve-Path $script:DEFAULT_BUNDLETOOL).Path
}

function Invoke-Update {
    Write-Host ""
    Write-Host "=[ BUNDLETOOL UPDATE ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Check for Updates ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Test-BundleToolUpdate
}
