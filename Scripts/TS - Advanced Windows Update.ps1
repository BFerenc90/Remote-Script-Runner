# Reset Windows Update Components


Write-Host @"

================ ADVANCED WINDOWS UPDATE TROUBLESHOOTER ================

State:
Started


=================================================================

"@

    Write-Host "1) Stopping Windows Update services..."
    Stop-Service -Name BITS, wuauserv, appidsvc, cryptsvc -Force -ErrorAction SilentlyContinue

    Write-Host "2) Removing QMGR data files..."
    Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue

    Write-Host "3) Renaming Windows Update related folders..."
    Rename-Item "$env:systemroot\SoftwareDistribution" "SoftwareDistribution_$dateToday" -ErrorAction SilentlyContinue
    Rename-Item "$env:systemroot\System32\catroot2" "catroot2_$dateToday" -ErrorAction SilentlyContinue
    Rename-Item "C:\ProgramData\application data\Microsoft\Network\Downloader" "Downloader_$dateToday" -ErrorAction SilentlyContinue

    Write-Host "4) Removing old Windows Update log..."
    Remove-Item "$env:systemroot\WindowsUpdate.log" -Force -ErrorAction SilentlyContinue

    Write-Host "5) Registering Windows Update related DLL files..."
    Set-Location "$env:systemroot\system32"

    $dlls = @(
        "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll",
        "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll",
        "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll",
        "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll",
        "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll",
        "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll",
        "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll",
        "wuwebv.dll"
    )

    foreach ($dll in $dlls) {
        regsvr32.exe /s $dll
    }

    Write-Host "6) Cleaning BITS jobs..."
    Import-Module BitsTransfer -ErrorAction SilentlyContinue
    Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue |
        Where-Object { $_.JobState -eq "TransientError" } |
        Remove-BitsTransfer -ErrorAction SilentlyContinue

    Get-BitsTransfer -AllUsers -ErrorAction SilentlyContinue |
        Where-Object { $_.JobState -eq "Suspended" } |
        Resume-BitsTransfer -ErrorAction SilentlyContinue

    Write-Host "7) Resetting BranchCache..."
    netsh branchcache reset

    Write-Host "8) Resetting Delivery Optimization cache..."
    Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service DoSvc -ErrorAction SilentlyContinue

    Write-Host "9) Starting Windows Update services..."
    Start-Service -Name BITS, wuauserv, appidsvc, cryptsvc -ErrorAction SilentlyContinue

    Set-Service BITS -StartupType Automatic -ErrorAction SilentlyContinue
    Set-Service wuauserv -StartupType Automatic -ErrorAction SilentlyContinue
    Set-Service cryptsvc -StartupType Automatic -ErrorAction SilentlyContinue

    Write-Host "10) Forcing Windows Update discovery..."
    wuauclt.exe /ResetAuthorization /DetectNow
    wuauclt.exe /reportnow
    UsoClient StartScan
    UsoClient StartDownload
    UsoClient StartInstall

    Write-Host "11) Triggering ConfigMgr actions..."
    $schedules = @(
        "{00000000-0000-0000-0000-000000000021}",
        "{00000000-0000-0000-0000-000000000108}",
        "{00000000-0000-0000-0000-000000000024}",
        "{00000000-0000-0000-0000-000000000023}",
        "{00000000-0000-0000-0000-000000000042}",
        "{00000000-0000-0000-0000-000000000113}"
    )

    foreach ($schedule in $schedules) {
        ([wmiclass]"ROOT\ccm:SMS_Client").TriggerSchedule($schedule) | Out-Null
    }

    (New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState()

    Write-Host "12) Executing built-in Windows Update troubleshooter..."
    Get-TroubleshootingPack -Path "C:\Windows\diagnostics\system\WindowsUpdate" |
        Invoke-TroubleshootingPack -Unattended

    Restart-Service wuauserv -Force -ErrorAction SilentlyContinue

    Write-Host @"

================ ADVANCED WINDOWS UPDATE TROUBLESHOOTER ================

State:
Completed successfully

=================================================================

"@


