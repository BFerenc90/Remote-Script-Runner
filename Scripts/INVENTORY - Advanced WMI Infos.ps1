
$outputFile = "C:\Temp\WMIInfos.txt"

if (-not (Test-Path $outputFile)) {
    New-Item -Path $outputFile -ItemType File -Force | Out-Null
}


function Show-Section {
    param(
        [string]$Title,
        [object]$Data
    )

    Write-Host "#########################################" -ForegroundColor DarkYellow
    Write-Host $Title -ForegroundColor DarkYellow
    Write-Host "#########################################" -ForegroundColor DarkYellow

    $titleForOutputFile = "#################  $Title  #################"
    Add-Content -Path $outputFile -Value $titleForOutputFile

    $Data | ForEach-Object {
        foreach ($property in $_.PSObject.Properties) {
            if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                            $line = "$($property.Name): $($property.Value)"
                            Write-Host $line

                            Add-Content -Path $outputFile -Value $line

            }
        }
    }

    Write-Host ""
}


# Get OS informations
$baseboard = Get-WmiObject -Class Win32_BaseBoard | select Manufacturer,Model,Name,SerialNumber,Product
$bios = Get-WmiObject -Class Win32_BIOS | select PSComputerName,SMBIOSBIOSVersion,Manufacturer,Name,SerialNumber,Version
$system = Get-WmiObject -Class Win32_ComputerSystem  | Select-Object Domain,PSComputerName,Manufacturer, SystemFamily, Model, Name, PartOfDomain, PrimaryOwnerName, UserName, @{Name='TotalPhysicalMemoryGB'; Expression={[math]::Round($_.TotalPhysicalMemory / 1GB, 2)}}

Show-Section -Title "Motherboard" -Data $baseboard
Show-Section -Title "BIOS" -Data $bios
Show-Section -Title "Computer System" -Data $system

# Get HW informations
$cpuInfo = Get-WmiObject -Class Win32_Processor  | select Caption,Manufacturer,Name,MaxClockSpeed,NumberOfCores,NumberOfLogicalProcessors
$csProductInfo = Get-WmiObject -Class Win32_ComputerSystemProduct   | select IdentifyingNumber,Name,Vendor,Version,Caption
$diskDriveInfo = Get-WmiObject -Class Win32_DiskDrive   | select Model,Caption,Status,@{Name='SizeGB'; Expression={[math]::Round($_.Size / 1GB, 2)}}
$logicalDiskInfo = Get-WmiObject -Class Win32_LogicalDisk   | select DeviceID,Name,DriveType,@{Name='FreeSpaceGB'; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},@{Name='SizeGB'; Expression={[math]::Round($_.Size / 1GB, 2)}},VolumeName,FileSystem
$partitionInfo = Get-WmiObject -Class Win32_DiskPartition   | select Name,BootPartition,PrimaryPartition,@{Name='SizeGB'; Expression={[math]::Round($_.Size / 1GB, 2)}}
$volumeInfo = Get-WmiObject -Class Win32_Volume   | select DriveLetter,FileSystem,@{Name='FreeSpaceGB'; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},Label
$memoryInfo = Get-WmiObject -Class Win32_PhysicalMemory   | select Caption,Name,Manufacturer,Capacity

Show-Section -Title "Processor" -Data $cpuInfo
Show-Section -Title "CSProduct" -Data $csProductInfo
Show-Section -Title "Disk" -Data $diskDriveInfo
Show-Section -Title "Logical Disk System" -Data $logicalDiskInfo
Show-Section -Title "Partition" -Data $partitionInfo
Show-Section -Title "Volume" -Data $volumeInfo
Show-Section -Title "RAM" -Data $memoryInfo

# Get Network informations
$networkDrives = Get-WmiObject -Class Win32_NetworkConnection   | select Name,AccessMask,Path,LocalName,RemoteName,Persistent,ConnectionState,Status
$networkAdapters = Get-WmiObject -Class Win32_NetworkAdapter   | Select-Object Description,Manufacturer,NetConnectionSID,NetEnabled,Name, ProductName, AdapterType, MACAddress
$networkConfig = Get-WmiObject -Class Win32_NetworkAdapterConfiguration   | select Description,DHCPEnabled,DHCPServer,DNSDomain,DNSServerSearchOrder,DefaultIPGateway,IPAddress,IPSubnet,MACAddress

Show-Section -Title "Network Drives" -Data $networkDrives
Show-Section -Title "Network Adapters" -Data $networkAdapters
Show-Section -Title "Network Configuration" -Data $networkConfig

# Get OS informations
$osInfo = Get-WmiObject -Class Win32_OperatingSystem   | select Name,Caption,BuildNumber,Version,FreePhysicalMemory,InstallDate,LastBootUpTime,LocalDateTime,NumberOfUsers,RegisteredUser,SystemDrive
Show-Section -Title "Operating System" -Data $osInfo

# Get User and Group informations
$group = Get-WmiObject -Class Win32_Group   | Select-Object Name
$adminUsers = Get-WmiObject -Class Win32_GroupUser   | Where-Object { $_.GroupComponent -match "Administrators|Rendszergazdák" } | Select-Object PartComponent, GroupComponent
$allUsers = Get-WmiObject -Class Win32_UserAccount   | Select-Object Name,SID,Domain

Show-Section -Title "Group" -Data $group
Show-Section -Title "Administrator Users" -Data $adminUsers
Show-Section -Title "All Users" -Data $allUsers

# Get Processes
$processes = Get-WmiObject -Class Win32_Process | Sort-Object Name
Add-Content -Path $outputFile -Value $processes

# Get Services
$services = Get-WmiObject -Class Win32_Service   | Select-Object DisplayName,Name,Status,PathName,StartMode,State | Sort-Object DisplayName
Add-Content -Path $outputFile -Value $services

# Get Installed Programes and Updates

$installedApps = Get-WmiObject -Class Win32_Product   | Select-Object Name,Version,Vendor,InstallDate | Sort-Object Name 
$updates = Get-WmiObject -Class Win32_QuickFixEngineering   | Select-Object Description, HotFixID, InstalledOn

Show-Section -Title "Installed Programes" -Data $installedApps
Show-Section -Title "Windows Updates" -Data $updates










