# build.ps1 - Build script with automatic stack detection
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
    
    $ParentDir = (Get-Item $PSScriptRoot).Parent.FullName
    Write-Log "Searching for a project in $ParentDir..."

    $ProjectType = "unknown"
    $ProjectFile = $null

    # 1. Check for .NET
    foreach ($Pattern in $Global:DevKitConfig.autoDetect.dotnet) {
        $Found = Get-ChildItem -Path $ParentDir -Filter $Pattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($Found) { $ProjectType = "dotnet"; $ProjectFile = $Found.FullName; break }
    }

    # 2. Check for Node.js
    if ($ProjectType -eq "unknown") {
        foreach ($Pattern in $Global:DevKitConfig.autoDetect.node) {
            $Found = Get-ChildItem -Path $ParentDir -Filter $Pattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($Found) { $ProjectType = "node"; $ProjectFile = $Found.FullName; break }
        }
    }

    # 3. Check for Python
    if ($ProjectType -eq "unknown") {
        foreach ($Pattern in $Global:DevKitConfig.autoDetect.python) {
            $Found = Get-ChildItem -Path $ParentDir -Filter $Pattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($Found) { $ProjectType = "python"; $ProjectFile = $Found.FullName; break }
        }
    }

    # 4. Check for Java
    if ($ProjectType -eq "unknown") {
        foreach ($Pattern in $Global:DevKitConfig.autoDetect.java) {
            $Found = Get-ChildItem -Path $ParentDir -Filter $Pattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($Found) { $ProjectType = "java"; $ProjectFile = $Found.FullName; break }
        }
    }

    if ($ProjectType -eq "unknown") {
        Write-Log "No supported project type detected in $ParentDir." "ERROR"
        exit 1
    }

    Write-Log "Detected project type: $ProjectType ($ProjectFile)"

    switch ($ProjectType) {
        "dotnet" {
            Write-Log "Starting .NET build (dotnet publish)..."
            $Config = $Global:DevKitConfig.build.defaultConfiguration
            $Output = Join-Path $ParentDir $Global:DevKitConfig.build.outputFolder
            dotnet publish $ProjectFile -c $Config -o $Output
        }
        "node" {
            Write-Log "Starting Node.js build (npm install & build)..."
            Set-Location (Get-Item $ProjectFile).Directory.FullName
            npm install
            npm run build
        }
        "python" {
            Write-Log "Setting up Python environment (pip install)..."
            Set-Location (Get-Item $ProjectFile).Directory.FullName
            pip install -r requirements.txt
        }
        "java" {
            if ($ProjectFile -like "*pom.xml") {
                Write-Log "Building Java project (Maven)..."
                mvn clean package -f $ProjectFile
            } else {
                Write-Log "Building Java project (Gradle)..."
                gradle build -p (Get-Item $ProjectFile).Directory.FullName
            }
        }
    }

    Write-Log "Build process completed successfully."

} catch {
    Write-Log "Build process failed: $_" "ERROR"
    exit 1
}
