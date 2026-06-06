$outputFile = "C:\Temp\InstalledUpdates.txt"

$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$HistoryCount = $Searcher.GetTotalHistoryCount()
$lastUpdates = $Searcher.QueryHistory(0, $HistoryCount) | select Date, Title  | sort Date -Descending

Write-Host $lastUpdates
Add-Content -Path $outputFile -Value $lastUpdates