# ========== LOGGING ========== #

function Log-Info {
    param([string]$Message)
    Write-Host "[*] " -ForegroundColor $COLOR_BLUE -NoNewline
    Write-Host $Message
}

function Log-Success {
    param([string]$Message)
    Write-Host "[+] " -ForegroundColor $COLOR_GREEN -NoNewline
    Write-Host $Message
}

function Log-Warning {
    param([string]$Message)
    Write-Host "[!] " -ForegroundColor $COLOR_YELLOW -NoNewline
    Write-Host $Message
}

function Log-Error {
    param([string]$Message)
    Write-Host "[-] " -ForegroundColor $COLOR_RED -NoNewline
    Write-Host $Message
}

function Log-Debug {
    param([string]$Message)
    Write-Host "[DEBUG] " -ForegroundColor $COLOR_MAGENTA -NoNewline
    Write-Host $Message
}

function Setup-Logging {
    if ($script:LOG_FILE -ne "") {
        # Create log file directory if needed
        $logDir = Split-Path -Parent $script:LOG_FILE
        
        if ($logDir -and -not (Test-Path $logDir)) {
            try {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            }
            catch {
                Log-Error "Cannot create log directory: $logDir"
                exit 1
            }
        }
        
        # Test write permissions
        try {
            New-Item -ItemType File -Path $script:LOG_FILE -Force | Out-Null
        }
        catch {
            Log-Error "Cannot write to log file: $script:LOG_FILE"
            exit 1
        }
        
        Log-Info "Logging to: $script:LOG_FILE"
        
        # Start transcript for logging
        Start-Transcript -Path $script:LOG_FILE -Append | Out-Null
    }
}
