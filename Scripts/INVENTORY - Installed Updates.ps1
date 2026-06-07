$Updates = Get-CimInstance Win32_QuickFixEngineering |
    Select-Object Description, HotFixID, InstalledOn |
    Sort-Object InstalledOn -Descending

$UpdateTable = $Updates |
    Format-Table -AutoSize |
    Out-String

Write-Host @"

================ WINDOWS UPDATES ================

$UpdateTable

=====================================================

"@
