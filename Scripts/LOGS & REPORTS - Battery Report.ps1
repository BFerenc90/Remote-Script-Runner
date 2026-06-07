# Battery report
$BatteryReport = "C:\Temp\BatteryReport.html"

try {
    powercfg /batteryreport /output $BatteryReport | Out-Null

    Write-Host @"

================ BATTERY REPORT ================

State:
Export successfull

Path of the report:
$BatteryReport

======================================================

"@
}
catch {
    Write-Host @"

================ BATTERY REPORT ================

State:
Export failed

Error:
$($_.Exception.Message)

======================================================

"@
}
