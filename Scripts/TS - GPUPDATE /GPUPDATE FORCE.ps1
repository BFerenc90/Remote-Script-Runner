# Group Policy Update

try {
    $result = gpupdate.exe /force | Out-String

    Write-Host @"

================ GROUP POLICY UPDATE ================

State:
Completed successfully

Result:

$result

=====================================================

"@
}
catch {
    Write-Host @"

================ GROUP POLICY UPDATE ================

State:
Execution failed

Error:
$($_.Exception.Message)

=====================================================

"@
}
