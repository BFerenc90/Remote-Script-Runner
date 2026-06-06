Write-Host "1) Stopping Windows Update Services..." 
Stop-Service -Name BITS 
Stop-Service -Name wuauserv 
Stop-Service -Name appidsvc 
Stop-Service -Name cryptsvc 

Write-Host "2) Renaming the Software Distribution and CatRoot Folder..."
$dateToday = Get-Date -Format "yyyyMMdd_HHmmss"
Rename-Item $env:systemroot\SoftwareDistribution "SoftwareDistribution_$dateToday" -ErrorAction SilentlyContinue
Rename-Item $env:systemroot\System32\catroot2 "catroot2_$dateToday" -ErrorAction SilentlyContinue
Rename-Item "C:\ProgramData\application data\Microsoft\Network\Downloader" "Downloader__$dateToday" -ErrorAction SilentlyContinue

Write-Host "3) Starting Windows Update Services..." 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc