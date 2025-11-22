# ========== HELP ========== #

function Show-Help {
    Write-Host @"
Usage: .\main.ps1 [OPTIONS] [COMMAND]

Windows PowerShell AAB to APKS converter with automatic dependency management.

COMMANDS:
    convert     Convert AAB files to APKs (default)
    validate    Validate AAB bundle integrity
    info        Show AAB file information
    batch       Batch process multiple files with queue management
    cleanup     Remove temporary and generated files
    update      Check for and update bundletool
    examples    Show usage examples

OPTIONS:
    -Help               Show this help message
    -Verbose            Enable verbose output (default)
    -Quiet              Disable verbose output
    -Interactive        Interactive mode (default)
    -NonInteractive     Non-interactive mode
    -Output <DIR>       Output directory (default: current)
    -Keystore <PATH>    Keystore file path
    -Alias <ALIAS>      Keystore alias
    -Password <PASS>    Keystore password
    -Secure             Use secure (hidden) password input
    -Theme <THEME>      Color theme: msf, dark, light, minimal (default: msf)
    -Mode <MODE>        Build mode: universal, system, persistent (default: universal)
    -Log <FILE>         Log output to file
    -Version            Show version information

EXAMPLES:
    .\main.ps1                                  # Interactive conversion (verbose)
    .\main.ps1 -Quiet                           # Silent conversion
    .\main.ps1 -NonInteractive                  # Batch conversion
    .\main.ps1 -Output .\apks -Verbose          # Verbose with custom output
    .\main.ps1 -Command validate                # Validate bundles
    .\main.ps1 -Command info                    # Show bundle info

REQUIREMENTS:
    - Windows 10/11 with PowerShell 5.1+
    - Java Development Kit (JDK 8+)
    - Internet connection for bundletool download

Created by Wilson Goal - 2025
"@
}

function Show-Examples {
    Write-Host ""
    Write-Host "=[ USAGE EXAMPLES ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "+ --- --=[ Practical Usage Guide ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Write-Host "BASIC USAGE:" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1                              # Interactive conversion" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -NonInteractive              # Batch conversion" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Command validate            # Validate bundles" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Write-Host "CUSTOM CONFIGURATION:" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -Output .\output             # Custom output directory" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Keystore mykey.keystore     # Custom keystore" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Alias myalias               # Custom alias" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Write-Host "ADVANCED OPTIONS:" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -Secure                      # Hidden password input" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Log conversion.log          # Log to file" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Mode system                 # System APKs only" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Write-Host "MAINTENANCE:" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -Command batch               # Batch processing mode" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Command cleanup             # Remove generated files" -ForegroundColor $COLOR_GREEN
    Write-Host "  .\main.ps1 -Command examples            # Show this help" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    
    Write-Host "WORKFLOW EXAMPLES:" -ForegroundColor $COLOR_CYAN
    Write-Host "  # Convert all AAB files in current directory" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -NonInteractive" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    Write-Host "  # Convert with custom settings and logging" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -Output .\apks -Keystore release.keystore -Log build.log" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    Write-Host "  # Batch process with progress tracking" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -Command batch" -ForegroundColor $COLOR_GREEN
    Write-Host ""
    Write-Host "  # Clean up after conversion" -ForegroundColor $COLOR_CYAN
    Write-Host "  .\main.ps1 -Command cleanup" -ForegroundColor $COLOR_GREEN
}
