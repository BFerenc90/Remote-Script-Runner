$InstalledApps = @(
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue
    Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue
) |
Where-Object { $_.DisplayName } |
Select-Object `
    @{Name="Name";Expression={$_.DisplayName}},
    @{Name="Version";Expression={$_.DisplayVersion}},
    @{Name="Vendor";Expression={$_.Publisher}},
    @{Name="InstallDate";Expression={$_.InstallDate}} |
Sort-Object Name

$AppTable = $InstalledApps |
    Format-Table -AutoSize |
    Out-String

Write-Host @"

================ INSTALLED APPLICATIONS ================

$AppTable

=========================================================

"@
