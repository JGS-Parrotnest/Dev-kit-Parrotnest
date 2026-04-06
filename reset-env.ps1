# reset-env.ps1 - Full local environment reset script
param(
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
    
    Write-Log "STARTING FULL ENVIRONMENT RESET..."

    # 1. Clean up the local database.
    Write-Log "Step 1: Cleaning up the local database..."
    & "$PSScriptRoot\cleanup-db.ps1" -ConfigPath $ConfigPath
    
    # 2. Remove generated and temporary build artifacts.
    Write-Log "Step 2: Cleaning temporary folders (obj, bin, node_modules)..."
    $ParentDir = (Get-Item $PSScriptRoot).Parent.FullName
    $FoldersToClean = @("obj", "bin", "node_modules", "target", "dist", "publish")
    
    foreach ($Folder in $FoldersToClean) {
        $FoundFolders = Get-ChildItem -Path $ParentDir -Filter $Folder -Recurse -Directory -ErrorAction SilentlyContinue
        foreach ($Found in $FoundFolders) {
            try {
                Write-Log "Deleting folder: $($Found.FullName)"
                Remove-Item $Found.FullName -Recurse -Force -ErrorAction Stop
            } catch {
                Write-Log "Could not delete $($Found.FullName). The folder may be locked." "WARNING"
            }
        }
    }

    Write-Log "Step 3: Clearing logs..."
    $LogFile = "$PSScriptRoot\" + $Global:DevKitConfig.logging.logFile
    if (Test-Path $LogFile) {
        Clear-Content $LogFile
    }

    Write-Log "FULL ENVIRONMENT RESET COMPLETED SUCCESSFULLY."

} catch {
    Write-Log "Environment reset failed: $_" "ERROR"
    exit 1
}
