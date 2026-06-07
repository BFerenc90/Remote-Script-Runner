# Serial Number
$Bios = Get-CimInstance Win32_BIOS
$SerialNumber = $Bios.SerialNumber

# CPU
$Cpu = Get-CimInstance Win32_Processor
$CpuName = $Cpu.Name

# RAM
$TotalRamGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)

# Disk
$Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$DiskInfo = foreach ($Disk in $Disks) {
    "$($Disk.DeviceID) - Free: $([math]::Round($Disk.FreeSpace / 1GB, 2)) GB / Total: $([math]::Round($Disk.Size / 1GB, 2)) GB"
}

# BIOS
$BiosManufacturer = $Bios.Manufacturer
$BiosVersion = ($Bios.SMBIOSBIOSVersion)

# Motherboard
$Board = Get-CimInstance Win32_BaseBoard
$BoardManufacturer = $Board.Manufacturer
$BoardProduct = $Board.Product

Write-Host @"

================ SYSTEM INFORMATIONS ================

Serial Number:
$SerialNumber

CPU:
$CpuName

RAM:
$TotalRamGB GB

BIOS:
Manufacturer: $BiosManufacturer
Version: $BiosVersion

Motherboard:
Manufacturer: $BoardManufacturer
Model: $BoardProduct

Disk:
$($DiskInfo -join "`n")

======================================================

"@
