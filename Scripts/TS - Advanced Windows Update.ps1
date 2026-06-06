# Windows Update related services
Write-Host "1) Stopping Windows Update Services..." 
Stop-Service -Name BITS 
Stop-Service -Name wuauserv 
Stop-Service -Name appidsvc 
Stop-Service -Name cryptsvc 

# BITS download queue clearing
Write-Host "2) Remove QMGR Data file..." 
Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue 

# Renaming the Windows Update and BITS related folders
Write-Host "3) Renaming the Software Distribution and CatRoot Folder..."
$dateToday = Get-Date -Format "yyyyMMdd_HHmmss"
Rename-Item $env:systemroot\SoftwareDistribution "SoftwareDistribution_$dateToday" -ErrorAction SilentlyContinue
Rename-Item $env:systemroot\System32\catroot2 "catroot2_$dateToday" -ErrorAction SilentlyContinue
Rename-Item "C:\ProgramData\application data\Microsoft\Network\Downloader" "Downloader__$dateToday" -ErrorAction SilentlyContinue

Write-Host "4) Removing old Windows Update log..." 
Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue 

# Reregister all the Windows Update related dll files
Set-Location $env:systemroot\system32 
Write-Host "5) Registering some DLLs..." 
regsvr32.exe /s atl.dll 
regsvr32.exe /s urlmon.dll 
regsvr32.exe /s mshtml.dll 
regsvr32.exe /s shdocvw.dll 
regsvr32.exe /s browseui.dll 
regsvr32.exe /s jscript.dll 
regsvr32.exe /s vbscript.dll 
regsvr32.exe /s scrrun.dll 
regsvr32.exe /s msxml.dll 
regsvr32.exe /s msxml3.dll 
regsvr32.exe /s msxml6.dll 
regsvr32.exe /s actxprxy.dll 
regsvr32.exe /s softpub.dll 
regsvr32.exe /s wintrust.dll 
regsvr32.exe /s dssenh.dll 
regsvr32.exe /s rsaenh.dll 
regsvr32.exe /s gpkcsp.dll 
regsvr32.exe /s sccbase.dll 
regsvr32.exe /s slbcsp.dll 
regsvr32.exe /s cryptdlg.dll 
regsvr32.exe /s oleaut32.dll 
regsvr32.exe /s ole32.dll 
regsvr32.exe /s shell32.dll 
regsvr32.exe /s initpki.dll 
regsvr32.exe /s wuapi.dll 
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wuaueng1.dll 
regsvr32.exe /s wucltui.dll 
regsvr32.exe /s wups.dll 
regsvr32.exe /s wups2.dll 
regsvr32.exe /s wuweb.dll 
regsvr32.exe /s qmgr.dll 
regsvr32.exe /s qmgrprxy.dll 
regsvr32.exe /s wucltux.dll 
regsvr32.exe /s muweb.dll 
regsvr32.exe /s wuwebv.dll 


# Deleting all BITS jobs which have errors during the download
Write-Host "6) Delete all BITS jobs..." 
Import-Module Bitstransfer
Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -like 'TransientError' } | Remove-BitsTransfer
Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -like 'SUSPENDED' } | Resume-BitsTransfer

Write-Host "7) Reset branchcache..." 
netsh branchcache reset

# The DO cache folder could be other location!
Write-Host "8) Resetting Delivery Optimization..."
Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service DoSvc -ErrorAction SilentlyContinue

Write-Host "9) Starting Windows Update Services..." 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc

Set-Service BITS -StartupType Automatic
Set-Service wuauserv -StartupType Automatic
Set-Service cryptsvc -StartupType Automatic

Write-Host "10) Execute gpupdate /force..." 
gpupdate.exe /Force

# Delete Windows Update client ID and reregister itself against the WSUS and report all installed and missing updates to the server
Write-Host "11) Forcing discovery..."
wuauclt.exe /ResetAuthorization /DetectNow
wuauclt.exe /reportnow
UsoClient StartScan
UsoClient StartDownload
UsoClient StartInstall    

# Triggering the following actions: Machine Policy Retrieval & Evaluation, Software Updates Scan, Software Updates Deployment Evaluation, Software Updates Assignment Evaluation
Write-Host "12) Triggering ConfigMgr Actions..."
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000021}') | out-null
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}') | out-null
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000024}') | out-null
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000023}') | out-null
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000042}') | out-null
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}') | out-null
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}') | out-null
# Refresh the clients state, reevaluate the compliance
(New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState()
    
Write-Host "13) Executing Built-in Windows Update Troubleshooter..."
Get-TroubleshootingPack -Path "C:\Windows\diagnostics\system\WindowsUpdate" | Invoke-TroubleshootingPack -Unattended
Restart-Service 'wuauserv'

Write-Host "14) Generating Windows Update log..."
Get-WindowsUpdateLog

# Execute SFC and DISM commands
Write-Host "15) Running system file check..."
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth

Write-Host "16) Checking pending reboot..."
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
    Write-Host "Reboot is pending!" -ForegroundColor Yellow
}
