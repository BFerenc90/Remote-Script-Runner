$neededTriggers = @{
"{00000000-0000-0000-0000-000000000021}" = "Machine policy retrieval & evaluation cycle"
"{00000000-0000-0000-0000-000000000022}" = "Machine policy evaluation cycle"
"{00000000-0000-0000-0000-000000000001}" = "Hardware inventory cycle"
"{00000000-0000-0000-0000-000000000003}" = "Discovery data collection cycle"
"{00000000-0000-0000-0000-000000000113}" = "Software updates scan cycle"
"{00000000-0000-0000-0000-000000000114}" = "Software updates deployment evaluation cycle"
"{00000000-0000-0000-0000-000000000031}" = "Software metering usage report cycle"
"{00000000-0000-0000-0000-000000000121}" = "Application deployment evaluation cycle"
"{00000000-0000-0000-0000-000000000032}" = "Windows installer source list update cycle"
}

$triggers = Get-WmiObject -Namespace "root\ccm\scheduler" -Class "CCM_Scheduler_History" | select ScheduleID, LastTriggerTime
$SMSClient = Get-WMIObject -Namespace "root\ccm" -Class SMS_Client -list

$success = $true
$result = foreach ($id in $neededTriggers.Keys) {

    $match = $triggers | Where-Object { $_.ScheduleID -eq $id }

    [PSCustomObject]@{
        ScheduleID      = $id
        ActionName      = $neededTriggers[$id]
        Exists          = [bool]$match
        LastTriggerTime = $match.LastTriggerTime
    }

    
        $SMSClient.TriggerSchedule($id)           

}