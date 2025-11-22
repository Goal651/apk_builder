<#
.SYNOPSIS
    AAB to APKS Converter Tool - Windows PowerShell Edition

.DESCRIPTION
    Convert Android App Bundle (.aab) files to APK format with automatic
    dependency management and user-friendly features.

.PARAMETER Help
    Show help message

.PARAMETER Version
    Show version information

.PARAMETER Verbose
    Enable verbose output (default: true)

.PARAMETER Quiet
    Disable verbose output

.PARAMETER Interactive
    Interactive mode (default: true)

.PARAMETER NonInteractive
    Non-interactive mode

.PARAMETER Output
    Output directory (default: current directory)

.PARAMETER Keystore
    Keystore file path

.PARAMETER Alias
    Keystore alias

.PARAMETER Password
    Keystore password

.PARAMETER Secure
    Use secure (hidden) password input

.PARAMETER Theme
    Color theme: msf, dark, light, minimal (default: msf)

.PARAMETER Mode
    Build mode: universal, system, persistent (default: universal)

.PARAMETER Log
    Log output to file

.PARAMETER Command
    Command to execute: convert, validate, info, batch, cleanup, update, examples

.EXAMPLE
    .\main.ps1
    Interactive conversion with verbose output

.EXAMPLE
    .\main.ps1 -NonInteractive -Output .\apks
    Batch conversion to custom output directory

.EXAMPLE
    .\main.ps1 -Command validate
    Validate AAB files

.NOTES
    Created by Wilson Goal - 2025
    Version 1.0.1
    Optimized for Windows 10/11 PowerShell
#>

param(
    [switch]$Help,
    [switch]$Version,
    [switch]$Verbose,
    [switch]$Quiet,
    [switch]$Interactive,
    [switch]$NonInteractive,
    [string]$Output,
    [string]$Keystore,
    [string]$Alias,
    [string]$Password,
    [switch]$Secure,
    [string]$Theme,
    [string]$Mode,
    [string]$Log,
    [ValidateSet('convert', 'validate', 'info', 'batch', 'cleanup', 'update', 'examples')]
    [string]$Command = 'convert'
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load all modules
. (Join-Path $scriptDir "src\Constants.ps1")
. (Join-Path $scriptDir "src\Theme.ps1")
. (Join-Path $scriptDir "src\Logger.ps1")
. (Join-Path $scriptDir "src\Config.ps1")
. (Join-Path $scriptDir "src\UI.ps1")
. (Join-Path $scriptDir "src\Utils.ps1")
. (Join-Path $scriptDir "src\Error.ps1")
. (Join-Path $scriptDir "src\Help.ps1")
. (Join-Path $scriptDir "src\BundleTool.ps1")
. (Join-Path $scriptDir "src\Keystore.ps1")
. (Join-Path $scriptDir "src\AAB.ps1")

# ========== MAIN ========== #

function Main {
    # Set theme first
    Set-Theme
    
    # Load configuration
    Load-Config
    
    # Handle help and version flags
    if ($Help) {
        Show-Header
        Show-Help
        exit 0
    }
    
    if ($Version) {
        Show-Version
        exit 0
    }
    
    # Apply command-line parameters
    if ($Verbose) { $script:VERBOSE = $true }
    if ($Quiet) { $script:VERBOSE = $false }
    if ($Interactive) { $script:INTERACTIVE = $true }
    if ($NonInteractive) { $script:INTERACTIVE = $false }
    if ($Output) { $script:OUTPUT_DIR = $Output }
    if ($Keystore) { $script:KEYSTORE_PATH = $Keystore }
    if ($Alias) { $script:KEYSTORE_ALIAS = $Alias }
    if ($Password) { $script:KEYSTORE_PASS = $Password }
    if ($Secure) { $script:SECURE_INPUT = $true }
    if ($Theme) { $script:THEME = $Theme; Set-Theme }
    if ($Mode) {
        if ($Mode -match '^(universal|system|persistent)$') {
            $script:BUILD_MODE = $Mode
        }
        else {
            Log-Error "Invalid build mode: $Mode. Use: universal, system, or persistent"
            exit 1
        }
    }
    if ($Log) { $script:LOG_FILE = $Log }
    
    # Initialize
    Write-Host "[*] Initializing AAB Converter..." -ForegroundColor $COLOR_BLUE
    Start-Sleep -Milliseconds 500
    
    # Show header immediately
    Show-Header
    Start-Sleep -Seconds 5
    
    Write-Host "[*] Performing system analysis..." -ForegroundColor $COLOR_BLUE
    Start-Sleep -Milliseconds 300
    
    # Check dependencies
    Test-Dependencies
    
    # Setup logging
    Setup-Logging
    
    # Save configuration after successful initialization
    Save-Config
    
    # Show ready message
    Write-Host "[+] AAB Converter initialized successfully!" -ForegroundColor $COLOR_GREEN
    Write-Host "[+] Ready for conversion operations." -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    # Create output directory if needed
    if ($script:OUTPUT_DIR -ne "." -and -not (Test-Path $script:OUTPUT_DIR)) {
        New-Item -ItemType Directory -Path $script:OUTPUT_DIR -Force | Out-Null
    }
    
    # Execute command
    switch ($Command) {
        'convert' {
            Write-Host "[*] Starting conversion process..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Invoke-Convert
        }
        'validate' {
            Write-Host "[*] Starting validation process..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Invoke-Validate
        }
        'info' {
            Write-Host "[*] Gathering bundle information..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Invoke-Info
        }
        'batch' {
            Write-Host "[*] Initializing batch processing mode..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Invoke-Batch
        }
        'cleanup' {
            Write-Host "[*] Starting cleanup operations..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Invoke-Cleanup
        }
        'update' {
            Write-Host "[*] Checking for updates..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Invoke-Update
        }
        'examples' {
            Write-Host "[*] Loading usage examples..." -ForegroundColor $COLOR_BLUE
            Start-Sleep -Milliseconds 200
            Show-Examples
        }
        default {
            Log-Error "Unknown command: $Command"
            Show-Help
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "=[ SESSION COMPLETE ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Wilson Goal's AAB Converter ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    Write-Host "[+] All operations completed successfully!" -ForegroundColor $COLOR_GREEN
}

# Entry point
try {
    Main
}
catch {
    Write-Host ""
    Write-Host "[-] An error occurred: $_" -ForegroundColor Red
    Write-Host "[-] Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}
finally {
    # Stop transcript if logging was enabled
    if ($script:LOG_FILE -ne "") {
        Stop-Transcript | Out-Null
    }
}
