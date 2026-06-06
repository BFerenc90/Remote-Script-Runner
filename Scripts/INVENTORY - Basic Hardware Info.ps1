
Get-ComputerInfo | Select `
    CsName,
    CsSystemSKUNumber,
    BiosSerialNumber,
    @{Name="RAM_GB";Expression={[math]::Round($_.CsTotalPhysicalMemory / 1GB, 2)}},
    CsProcessors

Get-Volume | Select `
    DriveLetter,
    @{Name="FreeSpace_GB";Expression={[math]::Round($_.SizeRemaining / 1GB, 2)}},
    @{Name="TotalSize_GB";Expression={[math]::Round($_.Size / 1GB, 2)}}

