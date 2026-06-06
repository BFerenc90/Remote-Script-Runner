$hostname = $env:COMPUTERNAME
$domain = (Get-CimInstance Win32_ComputerSystem).Domain

$diagnosticSummaryForHTML = ""

# HTML style
$htmlContent = @"
<!DOCTYPE html>
<html lang="hu">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Network and Performance / Hardware Diagnostic Report</title>
<style>
:root {
  --bg: #0b1020;
  --panel: #121933;
  --panel-2: #0f1530;
  --card: rgba(255,255,255,.06);
  --text: #ecf1ff;
  --muted: #a8b3d1;
  --line: rgba(255,255,255,.10);
  --ok: #1dbf73;
  --warn: #f5b700;
  --err: #ef4444;
  --info: #4f8cff;
  --accent: #6d7cff;
  --shadow: 0 14px 40px rgba(0,0,0,.28);
}
* { box-sizing: border-box; }
body {
  margin: 0;
  font-family: "Segoe UI", Roboto, Arial, sans-serif;
  background:
    radial-gradient(circle at top right, rgba(109,124,255,.22), transparent 28%),
    radial-gradient(circle at top left, rgba(29,191,115,.14), transparent 25%),
    linear-gradient(180deg, #0a1022 0%, #0b1020 100%);
  color: var(--text);
}
.wrapper { max-width: 1600px; margin: 0 auto; padding: 28px; }
.hero {
  background: linear-gradient(135deg, rgba(109,124,255,.22), rgba(255,255,255,.04));
  border: 1px solid var(--line);
  border-radius: 24px;
  padding: 28px;
  box-shadow: var(--shadow);
  display: grid;
  gap: 24px;
}
.hero h1 { margin: 0 0 10px; font-size: 34px; letter-spacing: .2px; }
.subtitle { color: var(--muted); font-size: 15px; line-height: 1.55; }
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-top: 24px;
}
.kpi {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 18px;
  padding: 18px;
  backdrop-filter: blur(6px);
}
.kpi .label { color: var(--muted); font-size: 12px; text-transform: uppercase; letter-spacing: .12em; white-space: nowrap;}
.kpi .value { margin-top: 8px; font-size: 28px; font-weight: 700; white-space: nowrap;}
.kpi .sub { margin-top: 4px; color: var(--muted); font-size: 13px; }
.scorecard {
  background: linear-gradient(180deg, rgba(255,255,255,.07), rgba(255,255,255,.04));
  border: 1px solid var(--line);
  border-radius: 22px;
  padding: 24px;
}
.status-ring {
  width: 132px; height: 132px; border-radius: 50%;
  margin: 4px auto 18px;
  display: grid; place-items: center;
  background:
    radial-gradient(circle at center, var(--panel) 52%, transparent 53%),
    conic-gradient(var(--err) 0 100%);
  box-shadow: inset 0 0 28px rgba(255,255,255,.07);
}
.status-ring .inner {
  width: 94px; height: 94px; border-radius: 50%;
  background: var(--panel);
  display: grid; place-items: center;
  border: 1px solid var(--line);
}
.score-title { text-align: center; font-size: 15px; color: var(--muted); }
.score-value { text-align: center; font-size: 26px; font-weight: 700; margin-top: 4px; }
.pill {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 7px 12px; border-radius: 999px;
  font-size: 12px; font-weight: 700; letter-spacing: .05em;
  border: 1px solid transparent; text-transform: uppercase;
}
.pill.ok { background: rgba(29,191,115,.14); color: #86efac; border-color: rgba(29,191,115,.34); }
.pill.warning { background: rgba(245,183,0,.12); color: #fde68a; border-color: rgba(245,183,0,.28); }
.pill.error { background: rgba(239,68,68,.12); color: #fca5a5; border-color: rgba(239,68,68,.28); }
.pill.info { background: rgba(79,140,255,.12); color: #93c5fd; border-color: rgba(79,140,255,.28); }
.grid-2 { display: grid; grid-template-columns: 1.05fr .95fr; gap: 20px; margin-top: 22px; }
.card {
  background: rgba(255,255,255,.045);
  border: 1px solid var(--line);
  border-radius: 22px;
  padding: 22px;
  box-shadow: var(--shadow);
}
.card h2 { margin: 0 0 18px; font-size: 20px; }
.info-table {
  width: 100%; border-collapse: collapse; font-size: 14px;
}
.info-table tr { border-bottom: 1px solid rgba(255,255,255,.08); }
.info-table tr:last-child { border-bottom: none; }
.info-table td { padding: 10px 0; vertical-align: top; }
.info-table td:first-child { color: var(--muted); width: 38%; }
.finding {
  border: 1px solid var(--line);
  border-left-width: 5px;
  border-radius: 16px;
  padding: 14px 16px;
  background: rgba(255,255,255,.03);
  margin-bottom: 12px;
}
.finding.error { border-left-color: var(--err); }
.finding.warning { border-left-color: var(--warn); }
.finding.ok { border-left-color: var(--ok); }
.finding-title {
  display:flex; justify-content:space-between; gap:10px; align-items:flex-start;
  font-weight: 600; margin-bottom: 8px;
}
.finding ul { margin: 8px 0 0 18px; color: var(--muted); }
.finding li { margin: 4px 0; }
.small { color: var(--muted); font-size: 13px; }
.section { margin-top: 22px; }
.cols-3 { display:grid; grid-template-columns: repeat(3, 1fr); gap:16px; }
.mini-card {
  background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding:16px;
}
.mini-card h3 { margin:0 0 8px; font-size:14px; color: var(--muted); text-transform: uppercase; letter-spacing: .1em; }
.mini-card .big { font-size: 24px; font-weight: 700; }
.list {
  margin: 0; padding-left: 18px; color: var(--muted); font-size: 14px;
}
.footer {
  color: var(--muted); font-size: 12px; text-align: center; margin: 22px 0 10px;
}
code {
  background: rgba(255,255,255,.06); padding: 2px 6px; border-radius: 6px; color: #dbeafe;
}
@media (max-width: 1024px) {
  .hero, .grid-2, .cols-3 { grid-template-columns: 1fr; }
  .kpi-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 640px) {
  .wrapper { padding: 14px; }
  .kpi-grid { grid-template-columns: 1fr; }
}

table {
        border-collapse: collapse;
        width: 100%;
        background: transparent;
        box-shadow: 0 1px 4px rgba(0,0,0,0.08);
    }

    th, td {
        border: 1px solid transparent;
        padding: 8px 10px;
        text-align: left;
        vertical-align: top;
    }

    th {
        background: transparent;
        color: white;
    }

    tr:nth-child(even) {
        background: transparent;
    }

    tr:hover {
        background: #1E2648;
    }

</style>
</head>
<body>
"@

$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$cpu  = Get-CimInstance Win32_Processor
$mb   = Get-CimInstance Win32_BaseBoard

$diskSize = [math]::Round($disk.Size/1GB,2)
$freediskSize = [math]::Round($disk.FreeSpace/1GB,2)
$diskInfo = "$freediskSize GB / $diskSize GB"

$totalRamBytes = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
$totalRAM = [math]::Round($totalRamBytes / 1GB, 2)
$ramInfo = "$totalRAM GB"

$cpuInfo = $cpu.Name

$mbProduct = $mb.Product
$mbManufacturer = $mb.Manufacturer
$mbInfo = "$mbProduct (Manufacturer: $mbManufacturer)"

$bios = Get-CimInstance Win32_BIOS
$serialNumber = $bios.SerialNumber

$netAdapter = Get-NetAdapter | Sort-Object Status, Name | select Name, InterfaceDescription, Status, LinkSpeed, MacAddress | ConvertTo-Html -Fragment
$netAdapterAdvancedPropertyGet = Get-NetAdapterAdvancedProperty -Name "*" | select Name, DisplayName, DisplayValue| ConvertTo-Html -Fragment
$ipconfigurationData = Get-NetIPConfiguration | Select-Object `
    InterfaceAlias,
    InterfaceDescription,
    @{Name='IPv4Address';Expression={
        if ($_.IPv4Address) { ($_.IPv4Address.IPAddress) -join ', ' } else { '-' }
    }},
    @{Name='IPv4DefaultGateway';Expression={
        if ($_.IPv4DefaultGateway) { ($_.IPv4DefaultGateway.NextHop) -join ', ' } else { '-' }
    }},
    @{Name='DNSServer';Expression={
        if ($_.DNSServer.ServerAddresses) { ($_.DNSServer.ServerAddresses) -join ', ' } else { '-' }
    }},
    @{Name='IPAssignment';Expression={
        $dhcpState = (Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4).Dhcp
        switch ($dhcpState) {
            'Enabled'  { 'DHCP' }
            'Disabled' { 'Static' }
            default    { $dhcpState }
        }
    }} | ConvertTo-Html -Fragment

Add-Type -AssemblyName System.Web

$routingTable = route print | Out-String
$routingTableEncoded = [System.Web.HttpUtility]::HtmlEncode($routingTable)
$routingTableHtml = "<pre>$routingTableEncoded</pre>"

$ipconfigAll = ipconfig /all | Out-String
$ipconfigAllEncoded = [System.Web.HttpUtility]::HtmlEncode($ipconfigAll)
$ipconfigAllHtml = "<pre>$ipconfigAllEncoded</pre>"

$arp = arp -a | Out-String
$arpEncoded = [System.Web.HttpUtility]::HtmlEncode($arp)
$arpHtml = "<pre>$arpEncoded</pre>"

$netstat = netstat -ano | Out-String
$netstatEncoded = [System.Web.HttpUtility]::HtmlEncode($netstat)
$netstatHtml = "<pre>$netstatEncoded</pre>"

$firewall = netsh advfirewall monitor show firewall | Out-String
$firewallEncoded = [System.Web.HttpUtility]::HtmlEncode($firewall)
$firewallHtml = "<pre>$firewallEncoded</pre>"

$firewallrules = netsh advfirewall firewall show rule name=all | Out-String
$firewallrulesEncoded = [System.Web.HttpUtility]::HtmlEncode($firewallrules)
$firewallrulesHtml = "<pre>$firewallrulesEncoded</pre>"


$connectionState = Get-NetIPInterface | Where-Object AddressFamily -eq IPv4 | Sort-Object InterfaceMetric | select InterfaceAlias, Dhcp, InterfaceMetric, NlMtu, ConnectionState | ConvertTo-Html -Fragment

$certificates = Get-ChildItem Cert:\LocalMachine\My | Select-Object Subject, NotBefore, NotAfter, HasPrivateKey | ConvertTo-Html -Fragment

$services = Get-Service dot3svc, Dhcp, Dnscache, NlaSvc, Netlogon, LanmanWorkstation, CryptSvc | Select-Object DisplayName, Status, StartType | ConvertTo-Html -Fragment

$netProfile = Get-NetConnectionProfile |
    Select-Object InterfaceAlias, Name, NetworkCategory, IPv4Connectivity, IPv6Connectivity |
    ConvertTo-Html -Fragment


$nicDrivers = Get-NetAdapter |
    Select-Object Name, InterfaceDescription, DriverInformation, DriverFileName, DriverVersion |
    ConvertTo-Html -Fragment



$since = (Get-Date).AddDays(-7)

$wiredAutoconfigLog = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName   = "Microsoft-Windows-Wired-AutoConfig/Operational"
    StartTime = $since
} | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, LevelDisplayName, OpcodeDisplayName, Message | ConvertTo-Html -Fragment


$nlaLog = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName   = "Microsoft-Windows-NlaSvc/Operational"
    StartTime = $since
} | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, LevelDisplayName, OpcodeDisplayName, Message | ConvertTo-Html -Fragment

$dhcpLogOp = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName   = "Microsoft-Windows-DHCP-Client/Operational"
    StartTime = $since
} | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, LevelDisplayName, OpcodeDisplayName, Message | ConvertTo-Html -Fragment

$dnsLogOp = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName   = "Microsoft-Windows-DNS-Client/Operational"
    StartTime = $since
} | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, LevelDisplayName, OpcodeDisplayName, Message | ConvertTo-Html -Fragment

$dhcpLogAdm = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName   = "Microsoft-Windows-DHCP-Client/Admin"
    StartTime = $since
} | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, LevelDisplayName, OpcodeDisplayName, Message | ConvertTo-Html -Fragment


$systemEvents = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{
    LogName = 'System'
    StartTime = $since
} | Where-Object {
    $_.LevelDisplayName -in 'Error','Warning', 'Critical', 'Hiba', 'Figyelmeztetés', 'Kritikus'
} | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, ProviderName, LevelDisplayName, Message | ConvertTo-Html -Fragment

$isDomainMember = (Get-CimInstance Win32_ComputerSystem).PartOfDomain 
$isDomainTrustOK = Test-ComputerSecureChannel

try{
    $nlTestBase = nltest /dsgetdc:corp.contoso.com | Out-String
    $nlTestEncoded = [System.Web.HttpUtility]::HtmlEncode($nlTestBase)
    $nlTest = "<pre>$nlTestEncoded</pre>"


}
catch{
    $nlTest = "The nltest failed"
}

$netadapterBindings = Get-NetAdapterBinding | select InterfaceAlias, ifDesc, Description, Enabled | ConvertTo-Html -Fragment


# System Event Log - WHEA related events

$resultsSystemEvents = ""

try {

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

    $events = Get-WinEvent -FilterHashtable @{
        LogName = "System"
    } -ErrorAction SilentlyContinue |

    Where-Object {
        ($providers -contains $_.ProviderName) -and
        (
            $_.LevelDisplayName -eq "Error" -or
            $_.LevelDisplayName -eq "Critical" -or
            $_.LevelDisplayName -eq "Warning"
        )
    } |

    Sort-Object TimeCreated -Descending

    $resultsSystemEvents += "<h2>System Event Log - Hardware Related Events</h2>"

    if ($events) {
        
        $diagnosticSummaryForHTML += "<span style='color:red;'>Hardware Errors in Event Logs Detected</span><br>"

        $resultsSystemEvents += @"
<table border='1' cellpadding='5' cellspacing='0'>
<tr>
    <th>TimeCreated</th>
    <th>Provider</th>
    <th>Event ID</th>
    <th>Level</th>
    <th>Message</th>
</tr>
"@

        foreach ($event in $events) {

            $message = $event.Message -replace '&', '&amp;'
            $message = $message -replace '<', '&lt;'
            $message = $message -replace '>', '&gt;'
            $message = $message -replace "`r`n", "<br>"
            $message = $message -replace "`n", "<br>"

            $resultsSystemEvents += @"
<tr>
    <td>$($event.TimeCreated)</td>
    <td>$($event.ProviderName)</td>
    <td>$($event.Id)</td>
    <td>$($event.LevelDisplayName)</td>
    <td>$message</td>
</tr>
"@
        }

        $resultsSystemEvents += "</table>"
    }
    else {

        $resultsSystemEvents += "<pre>No matching Warning/Error/Critical events found.</pre>"
    }

}
catch {

    $resultsSystemEvents += "<h2>System Event Log - Hardware Related Events</h2>"
    $resultsSystemEvents += "<pre>Error: $($_.Exception.Message)</pre>"

}

#BSOD / Unexpected Shutdown Events
$resultsBSOD = ""

$events = Get-WinEvent -FilterHashtable @{
    LogName = "System"
    Id = 41,1001,6008
} -ErrorAction SilentlyContinue |
Sort-Object TimeCreated -Descending

$resultsBSOD += "<h2>BSOD / Unexpected Shutdown Events</h2>"

if ($events) {

    $diagnosticSummaryForHTML += "<span style='color:red;'>BSOD or Unexpected Shutdown Events Detected</span><br>"

    $resultsBSOD += @"
<table border='1' cellpadding='5' cellspacing='0'>
<tr>
<th>TimeCreated</th>
<th>Provider</th>
<th>Event ID</th>
<th>Level</th>
<th>Message</th>
</tr>
"@

    foreach ($event in $events) {

        $message = $event.Message -replace '&', '&amp;'
        $message = $message -replace '<', '&lt;'
        $message = $message -replace '>', '&gt;'
        $message = $message -replace "`r`n", "<br>"

        $resultsBSOD += @"
<tr>
<td>$($event.TimeCreated)</td>
<td>$($event.ProviderName)</td>
<td>$($event.Id)</td>
<td>$($event.LevelDisplayName)</td>
<td>$message</td>
</tr>
"@
    }

    $resultsBSOD += "</table>"
}
else {

    $resultsBSOD += "<pre>No BSOD or unexpected shutdown events found.</pre>"
}


# BSOD dump existence check only

$resultsBSODFile = ""

$memoryDmpPath = "$env:SystemRoot\MEMORY.DMP"
$minidumpPath  = "$env:SystemRoot\Minidump"

$resultsBSODFile += "<h2>BSOD Dump File Check</h2>"

# MEMORY.DMP
$resultsBSODFile += "<h3>MEMORY.DMP</h3>"

if (Test-Path $memoryDmpPath) {

    $diagnosticSummaryForHTML += "<span style='color:red;'>Memory.dmp File Detected</span><br>"

    $memoryDmp = Get-Item $memoryDmpPath

    $resultsBSODFile += "<pre>"
    $resultsBSODFile += "Exists   : Yes`r`n"
    $resultsBSODFile += "Path     : $($memoryDmp.FullName)`r`n"
    $resultsBSODFile += "Size MB  : $([math]::Round($memoryDmp.Length / 1MB, 2))`r`n"
    $resultsBSODFile += "Modified : $($memoryDmp.LastWriteTime)`r`n"
    $resultsBSODFile += "</pre>"
}
else {

    $resultsBSODFile += "<pre>Exists: No</pre>"
}

# Minidump folder / files
$resultsBSODFile += "<h3>Minidump</h3>"

if (Test-Path $minidumpPath) {
    
    $diagnosticSummaryForHTML += "<span style='color:red;'>Minidump Folder Detected</span><br>"

    $minidumps = Get-ChildItem `
        $minidumpPath `
        -Filter "*.dmp" `
        -ErrorAction SilentlyContinue

    $resultsBSODFile += "<pre>"
    $resultsBSODFile += "Folder exists : Yes`r`n"
    $resultsBSODFile += "Dump files    : $($minidumps.Count)`r`n"
    $resultsBSODFile += "</pre>"
}
else {

    $resultsBSODFile += "<pre>Folder exists: No</pre>"
}


# Generate Energy report
Write-Host "Generating Energy Report... (10 sec)"
$energyReportPath = "$env:TEMP\energy-report.html"
powercfg /energy /output $energyReportPath /duration 10 | Out-Null

$energyHtml = Get-Content $energyReportPath -Raw

if ($energyHtml -match '(?is)<body.*?>(.*)</body>') {
    $energyBody = $matches[1]
}
else {
    $energyBody = $energyHtml
}

$resultsEnergy = ""

$resultsEnergy += @"
<h2>PowerCfg Energy Report</h2>
<div style='border:1px solid #ccc;padding:10px;margin:10px;overflow:auto;'>
$energyBody
</div>
"@


# Check Disk
Write-Host "Checking Disk..."
$checkDisk = chkdsk /scan | Out-String
$checkDiskEncoded = [System.Web.HttpUtility]::HtmlEncode($checkDisk)
$checkDiskHtml = "<pre>$checkDiskEncoded</pre>"

if (
    $checkDisk -match "found problems" -or
    $checkDisk -match "errors found" -or
    $checkDisk -match "corrupt" -or
    $checkDisk -match "failed" -or
    $checkDisk -match "cannot continue"
) {
    $diagnosticSummaryForHTML += "<span style='color:red;'>Check Disk: Error or Corruption Detected</span><br>"
}


# Checking Disk Health
$physicalDisks = Get-PhysicalDisk |
    Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, Size |
    ConvertTo-Html -Fragment

$badPhysicalDisks = $physicalDiskObjects | Where-Object {
    $_.HealthStatus -ne "Healthy" -or
    $_.OperationalStatus -ne "OK"
}

if ($badPhysicalDisks) {
    foreach ($disk in $badPhysicalDisks) {
        $diagnosticSummaryForHTML += "<span style='color:red;'>Physical Disk: $($disk.FriendlyName) - Health: $($disk.HealthStatus), Operational: $($disk.OperationalStatus)</span><br>"
    }
}


# Disk Drives
$diskDrives = Get-CimInstance Win32_DiskDrive |
    Select-Object Model, InterfaceType, MediaType, Status, Size, SerialNumber |
    ConvertTo-Html -Fragment

$badDiskDrives = $diskDriveObjects | Where-Object {
    $_.Status -ne "OK"
}

if ($badDiskDrives) {
    foreach ($disk in $badDiskDrives) {
        $diagnosticSummaryForHTML += "<span style='color:red;'>Disk Drive: $($disk.Model) - Status: $($disk.Status)</span><br>"

    }
}

# Storage Reliability
$storageReliability = Get-PhysicalDisk | ForEach-Object {
    try {
        $_ | Get-StorageReliabilityCounter |
            Select-Object `
                @{Name='Disk';Expression={$_.DeviceId}},
                Temperature,
                ReadErrorsTotal,
                WriteErrorsTotal,
                Wear,
                PowerOnHours,
                StartStopCycleCount
    }
    catch {}
} | ConvertTo-Html -Fragment

$badReliability = $storageReliabilityObjects | Where-Object {
    $_.ReadErrorsTotal -gt 0 -or
    $_.WriteErrorsTotal -gt 0 -or
    $_.Wear -gt 80 -or
    $_.Temperature -gt 60
}

if ($badReliability) {
    foreach ($item in $badReliability) {
        $diagnosticSummaryForHTML += "<span style='color:red;'>Storage Reliability: Disk $($item.Disk) - Temp: $($item.Temperature), ReadErrors: $($item.ReadErrorsTotal), WriteErrors: $($item.WriteErrorsTotal), Wear: $($item.Wear)</span><br>"
    }
}


# Windows Reliability
$resultsReliability = ""

try {

    $racData = Get-CimInstance `
        -Namespace "root\cimv2" `
        -ClassName Win32_ReliabilityRecords |
    Sort-Object TimeGenerated -Descending |
    Select-Object -First 100

    $resultsReliability += "<h2>Reliability Monitor Events</h2>"

    if ($racData) {

        $resultsReliability += "<table border='1' cellpadding='5' cellspacing='0'>"

        $resultsReliability += @"
<tr>
<th>TimeGenerated</th>
<th>SourceName</th>
<th>EventIdentifier</th>
<th>ProductName</th>
<th>Message</th>
</tr>
"@

        foreach ($item in $racData) {

            $resultsReliability += @"
<tr>
<td>$($item.TimeGenerated)</td>
<td>$($item.SourceName)</td>
<td>$($item.EventIdentifier)</td>
<td>$($item.ProductName)</td>
<td>$($item.Message)</td>
</tr>
"@
        }

        $resultsReliability += "</table>"
    }
    else {

        $resultsReliability += "<pre>No reliability records found.</pre>"
    }

}
catch {

    $resultsReliability += "<pre>Error: $($_.Exception.Message)</pre>"

}


# systeminfo
Write-Host "Generating Systeminfo Report..."
$systeminfo = systeminfo | Out-String
$systeminfoEncoded = [System.Web.HttpUtility]::HtmlEncode($systeminfo)
$systeminfoHtml = "<pre>$systeminfoEncoded</pre>"

# driver infos
Write-Host "Generating Driver Info Report..."
$resultsDriverQuery = ""

try {
    $driverCsv = cmd.exe /c "driverquery /v /fo csv" 2>&1

    $driverObjects = $driverCsv | ConvertFrom-Csv

    $resultsDriverQuery += "<h2>Driver Query</h2>"

    if ($driverObjects) {
        $resultsDriverQuery += $driverObjects |
            ConvertTo-Html -Fragment `
                -PreContent "<h3>Installed Drivers</h3>" |
            Out-String
    }
    else {
        $resultsDriverQuery += "<pre>No driver data returned.</pre>"
    }
}
catch {
    $resultsDriverQuery += "<h2>Driver Query</h2>"
    $resultsDriverQuery += "<pre>Error: $($_.Exception.Message)</pre>"
}


# Problematic devices in Device Manager
$problemDevices = Get-CimInstance Win32_PnPEntity |
    Where-Object { $_.ConfigManagerErrorCode -ne 0 } |
    Select-Object Name, Manufacturer, PNPClass, DeviceID, ConfigManagerErrorCode, Status |
    ConvertTo-Html -Fragment

if(Get-CimInstance Win32_PnPEntity |
    Where-Object { $_.ConfigManagerErrorCode -ne 0 } |
    Select-Object Name, Manufacturer, PNPClass, DeviceID, ConfigManagerErrorCode, Status){
    $diagnosticSummaryForHTML += "<span style='color:red;'>Problematic Device(s) found in the Device Manager</span><br>"
}





# Diagnostic Summary Evaluation
################################

if($diagnosticSummaryForHTML -eq ""){
    
    $diagnosticSummaryForHTML = "<span style='color:green;'>No Errors found during the Diagnostic</span><br>"
}


$htmlContent += @"
<div class="wrapper">
  <section class="hero">
    <div>
      <h1>Network and Performance / Hardware Diagnostic Report</h1>
      <div class="subtitle">
        Visual status report for the $hostname client machine.<br>
        The report highlights the network informations of the device.
      </div>
      <div class="kpi-grid">
        <div class="kpi"><div class="label">Hostname</div><div class="value" style="font-size:22px">$hostname</div><div class="sub">$domain</div></div>
        <div class="kpi"><div class="label">Serial</div><div class="value" style="font-size:22px">$serialNumber</div></div>
        <div class="kpi"><div class="label">CPU</div><div class="value" style="font-size:22px">$cpuInfo</div></div>
        <div class="kpi"><div class="label">RAM</div><div class="value" style="font-size:22px">$ramInfo</div></div>
        <div class="kpi"><div class="label">Disk</div><div class="value" style="font-size:22px">$diskInfo</div></div>
        <div class="kpi"><div class="label">Motherboard</div><div class="value" style="font-size:22px">$mbInfo</div></div>
        </div>
    </div>

  </section>

  <div class="grid-2">
    <section class="card">
      <h2>Network Informations</h2>
      <div class="small" style="margin-bottom:10px; font-weight: bold; color: white">Adapter Configuration</div>
      <div class="section small" style="margin-bottom:10px;">$netAdapter</div>
      
      <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>IP Configuration</div>
      <div class="section small" style="margin-bottom:10px;">$ipconfigurationData</div>

      <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Connection State & Metric</div>
      <div class="section small" style="margin-bottom:10px;">$connectionState</div>

      <br>
      <br>

      <h2>Diagnostic and Performance</h2>


      <span>Summary</span>
      <br>
      <span>$diagnosticSummaryForHTML</span>
      <br>
      <br>

      <details>
        <summary><b>Hardware Error in Event Logs</b></summary>
        <p>
            $resultsSystemEvents
      </p>
      </details>


      <details>
        <summary><b>Bluesceen Events / Unexpected Shutdowns</b></summary>
        <p>
            $resultsBSOD
      </p>
      </details>

      <details>
        <summary><b>MEMORY.DMP and Minidump</b></summary>
        <p>
            $resultsBSODFile
      </p>
      </details>

      <details>
        <summary><b>Energy Report</b></summary>
        <p>
            $resultsEnergy
      </p>
      </details>


      <details>
        <summary><b>Check Disk</b></summary>
        <p>
            $checkDiskHtml
      </p>
      </details>
      
      <details>
        <summary><b>Physical Disk Health / SMART Data</b></summary>
          <p>$physicalDisks</p>
          <p>$diskDrives</p>
          <p>$storageReliability</p>
      </details>

      <details>
        <summary><b>Reliability Results</b></summary>
        <p>
            $resultsReliability
      </p>
      </details>


      <details>
        <summary><b>Sysinfo</b></summary>
        <p>
            $systeminfoHtml
      </p>
      </details>

      <details>
        <summary><b>Driver Informations</b></summary>
        <p>
            $resultsDriverQuery
      </p>
      </details>

      <details>
          <summary><b>Problematic Devices in Device Manager</b></summary>
          <p>$problemDevices</p>
      </details>

      <br>
      <pre>Useful tools: perfmon /rel and perfmon /report and mdsched.exe for memory testing</pre>

    </section>

    <section class="card">

        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Drivers</div>
        <div class="small" style="margin-bottom:10px;">$nicDrivers</div>

        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Certificates</div>
        <div class="small" style="margin-bottom:10px;">$certificates</div>

        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Services</div>
        <div class="small" style="margin-bottom:10px;">$services</div>

        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Network Profile</div>
        <div class="small" style="margin-bottom:10px;">$netProfile</div>

        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Domain</div>
        <div class="small" style="margin-bottom:10px;">Domain member: $isDomainMember</div>
        <div class="small" style="margin-bottom:10px;">Domain trust: $isDomainTrustOK</div>
        <div class="small" style="margin-bottom:10px;">NLTEST:<br> $nltest</div>




    </section>

  </div>





  <div class="grid-2">
    <section class="card">
      <h2>Command Executions</h2>

          <details>
    <summary>IPCONFIG</summary>
    <p>
        $ipconfigAllHtml
    </p>
    </details>

    
    <details>
    <summary>ROUTING TABLE</summary>
    <p>
        $routingTableHtml
    </p>
    </details>

    <details>
    <summary>ARP TABLE</summary>
    <p>
        $arpHtml
    </p>
    </details>

        <details>
    <summary>PORT CONNECTIONS</summary>
    <p>
        $netstatHtml
    </p>
    </details>

        <details>
    <summary>FIREWALL STATE</summary>
    <p>
        $firewallHtml
    </p>
    </details>

        <details>
    <summary>FIREWALL RULE</summary>
    <p>
        <pre style="max-height:400px; max-width:650px;overflow:auto;">$firewallrulesHtml</pre>
    </p>
    </details>


    </section>

    <section class="card">
        <h2>Advanced Informations</h2>
        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Network Adapter Advanced Properties</div>

        <details>
            <summary>Show details</summary>
            <p>
                $netAdapterAdvancedPropertyGet
            </p>
        </details>

        <div class="small" style="margin-bottom:10px; font-weight: bold; color: white"><br>Network Adapter Bindings</div>
        <details>
            <summary>Show details</summary>
            <p>
                $netadapterBindings
            </p>
        </details>
    </section>

  </div>





    <div class="section">
    <section class="card section">
    <h2>Logs (last 7 days)</h2>

    <details>
        <summary>Wired Autoconfig</summary>
        <p>
            $wiredAutoconfigLog
        </p>
    </details>

    <details>
        <summary>NLA</summary>
        <p>
            $nlaLog
        </p>
    </details>

        <details>
        <summary>DHCP Operational Logs</summary>
        <p>
            $dhcpLogOp
        </p>
    </details>
    
    <details>
        <summary>DHCP Admin Logs</summary>
        <p>
            $dhcpLogAdm
        </p>
    </details>

        <details>
        <summary>DNS Operational Logs</summary>
        <p>
            $dnsLogOp
        </p>
    </details>


        <details>
        <summary>System Errors and Warnings in the last 7 days</summary>
        <p>
            $systemEvents
        </p>
    </details>

</div>

    





  </section>



</div>
</body>
</html>
"@



$outputPath = "C:\Temp\" + $hostname + "_NetworkAndHardwareDiagnostic_Report.html"

$htmlContent | Out-File -FilePath $outputPath -Encoding UTF8




