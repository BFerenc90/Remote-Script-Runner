# Output files
$htmlReport = "C:\Temp\Energyreport.html"

Write-Host "The process will run for 30 seconds to check the energy usage..."
Write-Host ""

try {

    # Full HTML report
    powercfg /energy /output $htmlReport /duration 30 | Out-Null


    Write-Host "Energyreport exported successfully."
    Write-Host ""
    Write-Host "HTML Report:"
    Write-Host $htmlReport

}
catch {

    Write-Host "Failed to generate Energyreport." -ForegroundColor Red
    Write-Host $_.Exception.Message

}