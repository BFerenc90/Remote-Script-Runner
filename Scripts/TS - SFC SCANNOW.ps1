$outputFile = "C:\Temp\sfcscannow.txt"

Write-Host "Executing SFC /SCANNOW..."
$sfcscannow = sfc /scannow | Out-String

Add-Content -Path $outputFile -Value $sfcscannow