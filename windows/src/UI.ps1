# ========== PROGRESS BAR ========== #

function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Processing"
    )
    
    $percentage = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity $Activity -Status "$Current of $Total" -PercentComplete $percentage
}

function Show-Spinner {
    param(
        [scriptblock]$ScriptBlock,
        [string]$Message = "Processing"
    )
    
    $job = Start-Job -ScriptBlock $ScriptBlock
    $spinChars = '|', '/', '-', '\'
    $i = 0
    
    while ($job.State -eq 'Running') {
        Write-Host "`r[*] $Message $($spinChars[$i % 4])" -NoNewline
        Start-Sleep -Milliseconds 100
        $i++
    }
    
    Write-Host "`r[*] $Message ✓" -ForegroundColor $COLOR_GREEN
    
    $result = Receive-Job -Job $job
    Remove-Job -Job $job
    return $result
}

function Show-Header {
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor $COLOR_RED
    Write-Host "║                                                                              ║" -ForegroundColor $COLOR_RED
    Write-Host "║                    █████╗  █████╗ ██████╗     ████████╗ ██████╗              ║" -ForegroundColor $COLOR_RED
    Write-Host "║                   ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██╔═══██╗             ║" -ForegroundColor $COLOR_RED
    Write-Host "║                   ███████║███████║██████╔╝       ██║   ██║   ██║             ║" -ForegroundColor $COLOR_RED
    Write-Host "║                   ██╔══██║██╔══██║██╔══██╗       ██║   ██║   ██║             ║" -ForegroundColor $COLOR_RED
    Write-Host "║                   ██║  ██║██║  ██║██████╔╝       ██║   ╚██████╔╝             ║" -ForegroundColor $COLOR_RED
    Write-Host "║                   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝        ╚═╝    ╚═════╝              ║" -ForegroundColor $COLOR_RED
    Write-Host "║                                                                              ║" -ForegroundColor $COLOR_RED
    Write-Host "║                 ██████╗ ██████╗ ███╗   ██╗██╗   ██╗███████╗██████╗ ████████╗ ║" -ForegroundColor $COLOR_RED
    Write-Host "║                ██╔════╝██╔═══██╗████╗  ██║██║   ██║██╔════╝██╔══██╗╚══██╔══╝ ║" -ForegroundColor $COLOR_RED
    Write-Host "║                ██║     ██║   ██║██╔██╗ ██║██║   ██║█████╗  ██████╔╝   ██║    ║" -ForegroundColor $COLOR_RED
    Write-Host "║                ██║     ██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██╔══██╗   ██║    ║" -ForegroundColor $COLOR_RED
    Write-Host "║                ╚██████╗╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║  ██║   ██║    ║" -ForegroundColor $COLOR_RED
    Write-Host "║                 ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝    ║" -ForegroundColor $COLOR_RED
    Write-Host "║                                                                              ║" -ForegroundColor $COLOR_RED
    Write-Host "║                        WINDOWS POWERSHELL EDITION v$VERSION                      ║" -ForegroundColor $COLOR_RED
    Write-Host "║                                                                              ║" -ForegroundColor $COLOR_RED
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor $COLOR_RED
    Write-Host ""
    Write-Host "                 =[ Wilson Goal's AAB to APKS Converter ]=" -ForegroundColor $COLOR_GREEN
    Write-Host "                 + --- --=[ Windows 10/11 Optimized ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host "                 + --- --=[ Auto-deps • Interactive ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host "                 + --- --=[ Feature-rich • User-friendly ]=-- --- +" -ForegroundColor $COLOR_GREEN
    Write-Host ""
}
