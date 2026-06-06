$outputFile = "C:\Temp\InstalledApps.txt"

$installedApps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select DisplayName, DisplayVersion | Where DisplayName | Sort DisplayName 

Write-Host $installedApps
Add-Content -Path $outputFile -Value $installedApps