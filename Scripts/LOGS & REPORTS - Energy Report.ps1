# Energy Report
$EnergyReport = "C:\Temp\EnergyReport.html"

Write-Host @"

================ ENERGY REPORT ================

Status:
The process will run for 30 seconds to analyze energy usage...

================================================

"@

try {
    powercfg /energy /output $EnergyReport /duration 30 | Out-Null

    if (Test-Path $EnergyReport) {
        $Status = "Successfully exported"
    }
    else {
        $Status = "Report was not generated"
    }

    Write-Host @"

================ ENERGY REPORT ================

Status:
$Status

HTML Report:
$EnergyReport

================================================

"@
}
catch {
    Write-Host @"

================ ENERGY REPORT ================

Status:
Failed to generate report

Error:
$($_.Exception.Message)

================================================

"@
}
