$outputFile = "C:\Temp\CheckDisk.txt"

Write-Host "Checking Disk..."
$checkDisk = chkdsk /scan | Out-String

Add-Content -Path $outputFile -Value $checkDisk