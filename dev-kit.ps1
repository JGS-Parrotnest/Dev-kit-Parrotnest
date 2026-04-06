# dev-kit.ps1 - Main orchestration script for the Parrotnest Dev-Kit
param(
    [string]$Action = "build", # Available actions: build, cleanup-db, reset-env, all
    [string]$ConfigPath = "$PSScriptRoot\config.json"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FormattedMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $FormattedMessage
    
    if ($Global:DevKitConfig.logging.enabled) {
        $LogFile = "$PSScriptRoot\" + $Global:DevKitConfig.logging.logFile
        $FormattedMessage | Out-File -FilePath $LogFile -Append
    }
}

try {
    if (-not (Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }
    $Global:DevKitConfig = Get-Content $ConfigPath | ConvertFrom-Json
    
    Write-Log "STARTING DEV-KIT EXECUTION (Action: $Action)..."

    switch ($Action) {
        "build" {
            & "$PSScriptRoot\build.ps1" -ConfigPath $ConfigPath
        }
        "cleanup-db" {
            & "$PSScriptRoot\cleanup-db.ps1" -ConfigPath $ConfigPath
        }
        "reset-env" {
            & "$PSScriptRoot\reset-env.ps1" -ConfigPath $ConfigPath
        }
        "all" {
            Write-Log "Running full cycle (reset-env -> build)..."
            & "$PSScriptRoot\reset-env.ps1" -ConfigPath $ConfigPath
            & "$PSScriptRoot\build.ps1" -ConfigPath $ConfigPath
        }
        default {
            Write-Log "Unknown action: $Action. Available actions: build, cleanup-db, reset-env, all." "ERROR"
            exit 1
        }
    }

    Write-Log "DEV-KIT EXECUTION COMPLETED SUCCESSFULLY."

} catch {
    Write-Log "An error occurred in the main dev-kit script: $_" "ERROR"
    exit 1
}
