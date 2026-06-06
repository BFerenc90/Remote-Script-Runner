
$exportFolder = "C:\Temp\HWELog.txt"

$providers = @(
    "WHEA-Logger",
    "Microsoft-Windows-WHEA-Logger",
    "Kernel-WHEA",
    "disk",
    "storahci",
    "stornvme",
    "Ntfs",
    "volmgr",
    "BugCheck",
    "Microsoft-Windows-Kernel-Power",
    "Display",
    "nvlddmkm",
    "amdkmdag",
    "Kernel-PnP",
    "MemoryDiagnostics-Results",
    "MemoryDiagnostics"
)

$events = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable  @{
    LogName = 'System'
    ProviderName = $providers
    Level = 1,2,3
} | select LevelDisplayName, TimeCreated, Message, ProviderName

Write-Host $events

Add-Content -Path "C:\Temp\HWELog.txt" -Value $events