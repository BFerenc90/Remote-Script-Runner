$Groups = Get-CimInstance Win32_Group | Select-Object -ExpandProperty Name

$AdminUsers = Get-WmiObject -Class Win32_GroupUser |
    Where-Object { $_.GroupComponent -match "Administrators|Rendszergazdák" } |
    ForEach-Object {
        ($_.PartComponent -split 'Name="')[1] -split '"' | Select-Object -First 1
    }

$AllUsers = Get-CimInstance Win32_UserAccount |
    Select-Object Name, Domain, SID

Write-Host @"

================ USERS AND GROUPS ================

Groups:

$($Groups -join "`n")

Administrators:

$($AdminUsers -join "`n")

Users:

$(
    $AllUsers | ForEach-Object {
        "$($_.Domain)\$($_.Name) - SID: $($_.SID)"
    } | Out-String
)

===========================================================

"@
