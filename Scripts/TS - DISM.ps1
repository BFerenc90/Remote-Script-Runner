# DISM Report
$dismReport = "C:\Temp\DISM_Report.txt"

try {
    DISM /Online /Cleanup-Image /RestoreHealth *> $dismReport

    Write-Host @"

================ DISM RESTORE HEALTH ================

State:
Completed successfully

Result:
$(Get-Content $dismReport -Raw)

====================================================

"@
}
catch {
    Write-Host @"

================ DISM RESTORE HEALTH ================

State:
Execution failed

Error:
$($_.Exception.Message)

====================================================

"@
}
