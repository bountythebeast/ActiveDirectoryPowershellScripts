<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Ensure you have your AWS profile set up.
        2. Run.
    
    Notes:
        This script was an early attempt to build a billing report. It is clunky and is not ideal but can be useful depending on your environment or level of debth.

#>

#gets the connection state, timestamp and workspaceid
$connectionstate = Get-WKSWorkspacesConnectionStatus | select-object -ExpandProperty ConnectionState
Write-host "ConnectionState Complete"
$lastknownuserconnectiontimestamp = Get-WKSWorkspacesConnectionStatus | select-object -ExpandProperty LastKnownUserConnectionTimestamp
Write-host "LastKnown Complete"
$workspaceID = Get-WKSWorkspacesConnectionStatus | Select-Object -ExpandProperty WorkspaceID
Write-host "WorkspaceID Complete"


Add-Content $home\desktop\connectionstate.txt $connectionstate #remove the ConnectionStateCheckTimestamp Column
add-content $home\desktop\workspaceID.txt $workspaceID

Write-host "Writing to file; Complete"

Write-host "Retrieving Usernames"
$currentcount = 0
foreach ($workspace in $workspaceID)
{
    $currentcount++
    $output = get-wksworkspaces -WorkspaceID $workspace | Select-Object -ExpandProperty UserName
    if($output.Length -lt 2)
    {
        Add-Content $home\Desktop\username.txt "Name Unavailable"
    }
    else
    {
        Add-Content $home\Desktop\username.txt $output
    }
    $status = [math]::round(($currentcount / $workspaceID.Count)*100)
    Write-Progress -Activity "Retrieving Usernames" -Status "$status% complete" -PercentComplete ($status)
}
Write-host "Usernames Complete"

Write-host "Retrieving workspace Computer Name"
$currentcount = 0
foreach ($id in $workspaceID)
{
    $currentcount++
    $output = get-wksworkspace -WorkspaceId $id | Select-Object -ExpandProperty ComputerName
    if($output.Length -lt 2)
    {
        Add-Content $home\Desktop\ComputerName.txt "Unavailable"
    }
    else
    {
        Add-Content $home\Desktop\ComputerName.txt $output
    }
    $status = [math]::round(($currentcount / $workspaceID.Count)*100)
    Write-Progress -Activity "Retrieving Usernames" -Status "$status% complete" -PercentComplete ($status)
}
Write-host "Completed retriving computer names"



Write-host "Cleaning up date file..."
foreach ($date in $lastknownuserconnectiontimestamp)
{
    $new = $date.ToString("MM/dd/yyyy")
    Add-Content $home\desktop\lastknownuserconnectiontimestamp.txt $new
}


Write-host "Concatinating all files"
Write-host "... reading them in to seperate arrays ..."

#setting variables and reading them in from text files... 
$connectionstate = gc $home\Desktop\connectionstate.txt;$lastknownuserconnectiontimestamp = gc $home\desktop\lastknownuserconnectiontimestamp.txt; $workspaceID = gc $home\desktop\workspaceID.txt; $User = gc $home\desktop\username.txt;$WorkspaceCompNames = gc $home\Desktop\ComputerName.txt;$count = 0
#end setting. 
$count=0
foreach($tempconnection in $connectionstate)
{
    $templastknown = $lastknownuserconnectiontimestamp[$count]
    $tempworkspace = $workspaceID[$count]
    $tempuser = $user[$count]
    $tempCompName = $WorkspaceCompNames[$count]
    $count++
    Add-Content $home\desktop\concatinated-files.txt "$tempconnection , $templastknown , $tempworkspace , $tempuser , $tempCompName"
    $status = [math]::round(($count/ $connectionstate.Count)*100)
    Write-Progress -Activity "Retrieving additional Informatin" -Status "$status% Complete" -PercentComplete ($status)
}
remove-item $home\desktop\connectionstate.txt
remove-item $home\desktop\workspaceID.txt
remove-item $home\desktop\username.txt
remove-item $home\desktop\lastknownuserconnectiontimestamp.txt
remove-item $home\desktop\ComputerName.txt

Read-host -Prompt "~~~ Script has Completed ~~~"
