# ============================================================
# Export Default Windows Event Logs
# Saves System, Application and Security logs
# into %TEMP%\EventLogs
# ============================================================

$exportFolder = "C:\Temp\EventLogs"
$dateToday = Get-Date -Format "yyyyMMdd_HHmmss"

# Create folder
if (-not (Test-Path $exportFolder)) {
    New-Item -Path $exportFolder -ItemType Directory -Force | Out-Null
}

# Default logs
$logs = @(
    "System",
    "Application",
    "Security"
)

foreach ($log in $logs) {

    try {

        $outputFile = $exportFolder + "\" + "$log" + "_" + "$dateToday.evtx"

        Write-Host "Exporting $log..."

        wevtutil epl $log $outputFile

    }
    catch {

        Write-Host "Failed to export $log" -ForegroundColor Red
        Write-Host $_.Exception.Message

    }
}

Write-Host ""
Write-Host "Done."
Write-Host "Saved to: $exportFolder"