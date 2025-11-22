# ========== ERROR HANDLING ========== #

function Invoke-RetryOperation {
    param(
        [int]$MaxAttempts,
        [string]$OperationName,
        [scriptblock]$ScriptBlock
    )
    
    $attempt = 1
    while ($attempt -le $MaxAttempts) {
        Log-Info "$OperationName (attempt $attempt/$MaxAttempts)"
        
        try {
            & $ScriptBlock
            return $true
        }
        catch {
            if ($attempt -lt $MaxAttempts) {
                Log-Warning "Operation failed, retrying in 3 seconds..."
                Start-Sleep -Seconds 3
            }
        }
        
        $attempt++
    }
    
    Log-Error "$OperationName failed after $MaxAttempts attempts"
    return $false
}
