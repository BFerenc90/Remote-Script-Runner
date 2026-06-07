# Hardware Error Events
$ExportFile = "C:\Temp\HWELog.txt"

$Providers = @(
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

$Events = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName      = 'System'
    ProviderName = $Providers
    Level        = 1,2,3
} |
Select-Object LevelDisplayName, TimeCreated, ProviderName, Message

$EventTable = $Events |
    Format-Table -Wrap -AutoSize |
    Out-String

$EventTable | Out-File $ExportFile -Encoding UTF8

Write-Host @"

================ HARDWARE ERROR EVENTS ================

Export File:
$ExportFile

Total Events:
$($Events.Count)

$EventTable

=======================================================

"@
