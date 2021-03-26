<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update the $outputpath with a location you'd like the logs to be generated at.
        2. Update the $logstokeep with the number of logs. This script was designed to be run at the top of the hour, so 24 files per day, 14 days of retention, 336 files.
        3. Update the $lockedout line. A | Where-Object name -NotLike "*x*" can be added to help remove large amounts of accounts that are set to a disabled state.

    Notes:
        THIS IS AN AUTOMATED SCRIPT - Designed to work with Windows Task Scheduler/Automation through Tidel or alternative.

        This will not unlock users, and is strictly for displaying/retrieving information.

        This script will AUTOMATICALLY clean up its output files. Update $logstokeep to modify retention time. 

        
#>


$datetime = Get-Date -Format "dd-MM-yyyy-HH"

#@@@@@@@@@ Modify this for output to share/runas Tidal, etc @@@@@@@@@#

$outputpath = "\\server\share"
$logstokeep = 336 # Number of logs to keep. Will delete the oldest (336 is keep 1 log every 1 hour for 14 days...) not tested... but it won't delete the 3 logs i had for testing. 

#@@@@@@@@@ Modify this for output to share/runas Tidal, etc @@@@@@@@@#



$output = "$outputpath\$datetime.txt" # $home is the current accounts user directory, IE C:\users\scimboli\... done for testing. 
$lockedout = Search-ADAccount -LockedOut | Where-Object name -NotLike "Guest" | select -ExpandProperty SamAccountName | Sort-Object

foreach ($username in $lockedout)
{
    $fullname = (Get-ADUser $username -Properties Displayname).Displayname

    $DCCounter = 0  
    $LockedOutStats = @()    
    #Get all domain controllers in domain 
    $DomainControllers = Get-ADDomainController -Filter *
    $PDCEmulator = ($DomainControllers | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"})  
    Write-Verbose "Finding the domain controllers in the domain" 
    Foreach($DC in $DomainControllers)
    { 
        $DCCounter++ 
        Write-Progress -Activity "Contacting DCs for lockout info" -Status "Querying $($DC.Hostname)" -PercentComplete (($DCCounter/$DomainControllers.Count) * 100) 
        Write-Verbose "Finding the domain controllers that Authenticated the Password"
        Try 
        { 
            $UserInfo = Get-ADUser -Identity $username  -Server $DC.Hostname -Properties LastLogonDate -ErrorAction Stop 
            Write-Verbose "Bad Password Attempt count collected"
        } 
        Catch 
        { 
            # Write-Warning $_ 
            Continue 
        } 
        If($UserInfo.LastBadPasswordAttempt) 
        {     
            $LockedOutStats += New-Object -TypeName PSObject -Property @{ 
            Name   = $UserInfo.SamAccountName 
            SID    = $UserInfo.SID.Value 
            LockedOut      = $UserInfo.LockedOut 
            BadPwdCount    = $UserInfo.BadPwdCount 
            BadPasswordTime= $UserInfo.BadPasswordTime     
            DomainController       = $DC.Hostname 
            AccountLockoutTime     = $UserInfo.AccountLockoutTime 
            LastLogonDate = ($UserInfo.LastLogonDate).ToLocalTime() 
            }   
        }#end if 
    }#end foreach DCs 
    Write-Progress -Completed $true
    $LockedOutStats | Format-Table -Property Name,LockedOut,DomainController,BadPwdCount,AccountLockoutTime,LastBadPasswordAttempt -AutoSize 
    #Get User Info 
    Try 
    {   
        Write-Verbose "Querying event log on $($PDCEmulator.HostName)" 
        Write-Verbose "Collecting Event Log"
        $LockedOutEvents = Get-WinEvent -ComputerName $PDCEmulator.HostName -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending 
    } 
    Catch  
    {   
        Write-Warning $_ 
        Continue 
    }#end catch      


    # event conversion
    add-content $output "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    Add-Content $output "Lockout information for $fullname | $username"
    Foreach($Event in $LockedOutEvents) 
    {     
        If($Event | Where {$_.Properties[2].value -match $UserInfo.SID.Value}) 
        {  
            $Event | Select-Object -Property @( 
                @{Label = 'User';       Expression = {$_.Properties[0].Value}} 
                @{Label = 'DomainController';   Expression = {$_.MachineName}} 
                @{Label = 'EventId';    Expression = {$_.Id}} 
                @{Label = 'LockedOutTimeStamp'; Expression = {$_.TimeCreated}} 
                @{Label = 'Message';    Expression = {$_.Message -split "`r" | Select -First 1}} 
                @{Label = 'LockedOutLocation';  Expression = {$_.Properties[1].Value}}
            ) 
            $lockoutdc = $event.MachineName
            $lockedouttimestamp = $event.TimeCreated
            $lockoutlocation = $event.Properties[1].Value
            Add-Content $output "Lockout DC:      $lockoutdc"
            Add-Content $output "Lockout Time:    $lockedouttimestamp"
            Add-Content $output "Machine Lockout: $lockoutlocation"
            Add-Content $output " "

            $lockoutdc = ""
            $lockedouttimestamp = ""
            $lockoutlocation = ""
            $Event = ""
        
        }#end ifevent 
    }#end foreach lockedout event
$username = $null
$fullname = $null
$adout = $null
}#end global foreach

gci $outputpath -Recurse | where {-not $_.PsIsContainer}| sort CreationTime -Descending | select -Skip $logstokeep | Remove-item -Force
