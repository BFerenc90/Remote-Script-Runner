# Reset Windows Update Components
$dateToday = Get-Date -Format "yyyyMMdd_HHmmss"

try {
    Write-Host "Stopping Windows Update Services..."
    Stop-Service -Name BITS, wuauserv, appidsvc, cryptsvc -ErrorAction Stop

    Write-Host "Renaming SoftwareDistribution, CatRoot2 and Downloader folders..."
    Rename-Item "$env:systemroot\SoftwareDistribution" "SoftwareDistribution_$dateToday" -ErrorAction SilentlyContinue
    Rename-Item "$env:systemroot\System32\catroot2" "catroot2_$dateToday" -ErrorAction SilentlyContinue
    Rename-Item "C:\ProgramData\application data\Microsoft\Network\Downloader" "Downloader_$dateToday" -ErrorAction SilentlyContinue

    Write-Host "Starting Windows Update Services..."
    Start-Service -Name BITS, wuauserv, appidsvc, cryptsvc -ErrorAction Stop

    Write-Host @"

================ RESET WINDOWS UPDATE ================

State:
Completed successfully

Actions:
- Windows Update services stopped
- SoftwareDistribution renamed
- CatRoot2 renamed
- Downloader folder renamed
- Windows Update services started

Timestamp:
$dateToday

======================================================

"@
}
catch {
    Write-Host @"

================ RESET WINDOWS UPDATE ================

State:
Execution failed

Error:
$($_.Exception.Message)

======================================================

"@
}
