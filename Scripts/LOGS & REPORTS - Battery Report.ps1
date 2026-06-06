# Output files
$htmlReport = "C:\Temp\Batteryreport.html"

Write-Host "Generating Battery reports..."
Write-Host ""

try {

    # Full HTML report
    powercfg /batteryreport /output $htmlReport | Out-Null


    Write-Host "Batteryreport exported successfully."
    Write-Host ""
    Write-Host "HTML Report:"
    Write-Host $htmlReport

}
catch {

    Write-Host "Failed to generate Battery Report." -ForegroundColor Red
    Write-Host $_.Exception.Message

}