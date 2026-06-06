# Output files
$htmlReport = "C:\Temp\GPResult.html"

Write-Host "Generating GPResult reports..."
Write-Host ""

try {

    # Full HTML report (Computer + User policies)
    gpresult /H $htmlReport /F | Out-Null


    Write-Host "GPResult exported successfully."
    Write-Host ""
    Write-Host "HTML Report:"
    Write-Host $htmlReport

}
catch {

    Write-Host "Failed to generate GPResult." -ForegroundColor Red
    Write-Host $_.Exception.Message

}