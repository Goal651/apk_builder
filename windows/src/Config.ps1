# ========== CONFIGURATION ========== #

function Load-Config {
    $configFile = Join-Path $env:USERPROFILE ".aab-converter.conf"
    
    if (Test-Path $configFile) {
        Log-Info "Loading configuration from $configFile"
        
        # Read and parse config file
        Get-Content $configFile | ForEach-Object {
            if ($_ -match '^([^#=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim().Trim('"')
                
                switch ($key) {
                    "VERBOSE" { $script:VERBOSE = [bool]::Parse($value) }
                    "INTERACTIVE" { $script:INTERACTIVE = [bool]::Parse($value) }
                    "OUTPUT_DIR" { $script:OUTPUT_DIR = $value }
                    "KEYSTORE_PATH" { $script:KEYSTORE_PATH = $value }
                    "KEYSTORE_ALIAS" { $script:KEYSTORE_ALIAS = $value }
                    "BUILD_MODE" { $script:BUILD_MODE = $value }
                    "SECURE_INPUT" { $script:SECURE_INPUT = [bool]::Parse($value) }
                    "THEME" { $script:THEME = $value }
                }
            }
        }
    }
}

function Save-Config {
    $configFile = Join-Path $env:USERPROFILE ".aab-converter.conf"
    Log-Info "Saving configuration to $configFile"
    
    $configContent = @"
# AAB Converter Configuration
# Generated automatically - edit with caution

VERBOSE=$VERBOSE
INTERACTIVE=$INTERACTIVE
OUTPUT_DIR="$OUTPUT_DIR"
KEYSTORE_PATH="$KEYSTORE_PATH"
KEYSTORE_ALIAS="$KEYSTORE_ALIAS"
BUILD_MODE="$BUILD_MODE"
SECURE_INPUT=$SECURE_INPUT
THEME="$THEME"
"@
    
    Set-Content -Path $configFile -Value $configContent
}
