# SFC Report
$sfcReport = "C:\Temp\SFC_Report.txt"

try {
    Start-Process `
        -FilePath "sfc.exe" `
        -ArgumentList "/scannow" `
        -Wait `
        -RedirectStandardOutput $sfcReport `
        -NoNewWindow

    Write-Host @"

================ SYSTEM FILE CHECK ================

State:
Completed successfully

Result:
$(Get-Content $sfcReport -Raw)

==================================================

"@
}
catch {
    Write-Host @"

================ SYSTEM FILE CHECK ================

State:
Execution failed

Error:
$($_.Exception.Message)

==================================================

"@
}
