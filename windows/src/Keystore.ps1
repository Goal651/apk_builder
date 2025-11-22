# ========== KEYSTORE MANAGEMENT ========== #

function New-Keystore {
    param(
        [string]$KeystorePath,
        [string]$KeystoreAlias,
        [string]$KeystorePassword
    )
    
    if (Test-Path $KeystorePath) {
        Log-Info "Keystore already exists: $KeystorePath"
        # Validate existing keystore
        if (Test-Keystore -KeystorePath $KeystorePath -KeystoreAlias $KeystoreAlias -KeystorePassword $KeystorePassword) {
            Log-Success "Keystore validation passed"
            return $true
        }
        else {
            Log-Warning "Existing keystore is invalid, recreating..."
        }
    }
    
    Log-Info "Creating keystore: $KeystorePath"
    
    # Ensure keystore directory exists
    $ksDir = Split-Path -Parent $KeystorePath
    if ($ksDir -and -not (Test-Path $ksDir)) {
        try {
            New-Item -ItemType Directory -Path $ksDir -Force | Out-Null
        }
        catch {
            Log-Error "Cannot create keystore directory: $ksDir"
            return $false
        }
    }
    
    # Default dname
    $dname = "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown"
    
    if ($script:INTERACTIVE) {
        Write-Host ""
        Write-Host "=[ KEYSTORE CONFIGURATION ]=" -ForegroundColor $COLOR_GREEN
        Write-Host "+ --- --=[ Certificate Information ]=-- --- +" -ForegroundColor $COLOR_GREEN
        Write-Host ""
        Write-Host "[*] This information will be used to create your app signing certificate" -ForegroundColor $COLOR_CYAN
        Write-Host "[*] Press Enter to use default values shown in brackets" -ForegroundColor $COLOR_CYAN
        Write-Host ""
        
        $cn = Read-Host "[?] Your name or company name [Unknown]"
        if ([string]::IsNullOrWhiteSpace($cn)) { $cn = "Unknown" }
        
        $ou = Read-Host "[?] Department or team name [Unknown]"
        if ([string]::IsNullOrWhiteSpace($ou)) { $ou = "Unknown" }
        
        $o = Read-Host "[?] Company or organization name [Unknown]"
        if ([string]::IsNullOrWhiteSpace($o)) { $o = "Unknown" }
        
        $l = Read-Host "[?] City or locality [Unknown]"
        if ([string]::IsNullOrWhiteSpace($l)) { $l = "Unknown" }
        
        $st = Read-Host "[?] State or province [Unknown]"
        if ([string]::IsNullOrWhiteSpace($st)) { $st = "Unknown" }
        
        $c = Read-Host "[?] Country code (2 letters, e.g., US, GB) [Unknown]"
        if ([string]::IsNullOrWhiteSpace($c)) { $c = "Unknown" }
        
        $dname = "CN=$cn, OU=$ou, O=$o, L=$l, ST=$st, C=$c"
        Write-Host ""
        Log-Info "Certificate details configured"
    }
    
    try {
        $keytoolArgs = @(
            "-genkeypair",
            "-v",
            "-keystore", $KeystorePath,
            "-alias", $KeystoreAlias,
            "-keyalg", "RSA",
            "-keysize", "2048",
            "-validity", "10000",
            "-storepass", $KeystorePassword,
            "-keypass", $KeystorePassword,
            "-dname", $dname
        )
        
        $process = Start-Process -FilePath "keytool" -ArgumentList $keytoolArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            Log-Error "Failed to create keystore"
            return $false
        }
        
        Log-Success "Keystore created successfully"
        # Validate the newly created keystore
        return Test-Keystore -KeystorePath $KeystorePath -KeystoreAlias $KeystoreAlias -KeystorePassword $KeystorePassword
    }
    catch {
        Log-Error "Failed to create keystore: $_"
        return $false
    }
}

function Test-Keystore {
    param(
        [string]$KeystorePath,
        [string]$KeystoreAlias,
        [string]$KeystorePassword
    )
    
    if (-not (Test-Path $KeystorePath)) {
        Log-Error "Keystore file not found: $KeystorePath"
        return $false
    }
    
    try {
        $keytoolArgs = @(
            "-list",
            "-keystore", $KeystorePath,
            "-storepass", $KeystorePassword,
            "-alias", $KeystoreAlias
        )
        
        $process = Start-Process -FilePath "keytool" -ArgumentList $keytoolArgs -NoNewWindow -Wait -PassThru -RedirectStandardOutput "NUL"
        
        if ($process.ExitCode -ne 0) {
            Log-Error "Keystore validation failed - invalid keystore, alias, or password"
            return $false
        }
        
        Log-Success "Keystore validation passed"
        return $true
    }
    catch {
        Log-Error "Keystore validation failed: $_"
        return $false
    }
}
