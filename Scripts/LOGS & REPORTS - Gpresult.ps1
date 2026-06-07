# GPResult
$GPResultReport = "C:\Temp\GPResult.html"

try {
    gpresult /H $GPResultReport /F | Out-Null

    Write-Host @"

================ GPRESULT REPORT ================

Status:
Successfully exported

HTML Report:
$GPResultReport

=================================================

"@
}
catch {
    Write-Host @"

================ GPRESULT REPORT ================

Status:
Failed to generate report

Error:
$($_.Exception.Message)

=================================================

"@
}
