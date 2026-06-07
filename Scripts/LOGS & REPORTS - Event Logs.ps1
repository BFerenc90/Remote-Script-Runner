# Event Logs Export
$ExportFolder = "C:\Temp\EventLogs"
$DateToday = Get-Date -Format "yyyyMMdd_HHmmss"

if (-not (Test-Path $ExportFolder)) {
    New-Item -Path $ExportFolder -ItemType Directory -Force | Out-Null
}

$Logs = @(
    "System",
    "Application",
    "Security"
)

$ExportResults = @()

foreach ($Log in $Logs) {
    try {
        $OutputFile = Join-Path $ExportFolder "$($Log)_$DateToday.evtx"

        wevtutil epl $Log $OutputFile

        $ExportResults += [PSCustomObject]@{
            Log    = $Log
            Status = "Exported"
            File   = $OutputFile
        }
    }
    catch {
        $ExportResults += [PSCustomObject]@{
            Log    = $Log
            Status = "Failed"
            File   = $_.Exception.Message
        }
    }
}

$ResultTable = $ExportResults |
    Format-Table -AutoSize |
    Out-String

Write-Host @"

================ EVENT LOG EXPORT ================

Export Folder:
$ExportFolder

$ResultTable

==================================================

"@
