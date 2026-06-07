# Check Disk Report

try {
    $checkDisk = chkdsk /scan | Out-String

    Write-Host @"

================ CHECK DISK ================

State:
Scan completed successfully

Result:
$checkDisk

======================================================

"@
}
catch {
    Write-Host @"

================ CHECK DISK ================

State:
Scan failed

Error:
$($_.Exception.Message)

======================================================

"@
}
