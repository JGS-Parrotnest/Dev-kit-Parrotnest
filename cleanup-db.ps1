# cleanup-db.ps1 - Database cleanup utility for local development
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
    
    Write-Log "Starting database cleanup..."

    # Search for matching database files in the parent directory tree.
    $ParentDir = (Get-Item $PSScriptRoot).Parent.FullName
    $DbName = $Global:DevKitConfig.database.fileName
    
    Write-Log "Searching for database file '$DbName' in $ParentDir..."
    
    $DbFiles = Get-ChildItem -Path $ParentDir -Filter $DbName -Recurse -ErrorAction SilentlyContinue
    
    if ($DbFiles) {
        foreach ($File in $DbFiles) {
            try {
                Write-Log "Deleting database file: $($File.FullName)"
                Remove-Item $File.FullName -Force -ErrorAction Stop
                Write-Log "Database file deleted successfully."
            } catch {
                Write-Log "Could not remove $($File.FullName). The file may be used by another process." "WARNING"
            }
        }
    } else {
        Write-Log "No database files found to delete." "INFO"
    }

} catch {
    Write-Error "Database cleanup failed: $_"
    exit 1
}
