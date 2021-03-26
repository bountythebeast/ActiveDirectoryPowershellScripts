<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Start script
        2. Enter the UserID of the locked out individual (or service account) when prompted.
        3. If they are currently locked out, you will be prompted to unlock them. 
        4. You will be prompted to re-run for another user.
    
    Notes:
        This script was designed to be run by a *DOMAIN ADMIN* or equivilent due to direct query of the event services of domain controllers. 

        $unlockaccount can be updated to automatically unlock the user, or not prompt if that is prefered. 

        The run again may be broken. Not sure if I ever got around to fixing it. This script was originally created in 2018.
        
#>



$runagain = $true

if($runagain -ne $false) 
{
    $username = Read-Host "Please Enter the Locked UID: "
    $DCCounter = 0  
    $unlockaccount = "Ask".ToLower() #options: Ask, Yes, No
    $LockedOutStats = @()    

    Try 
    { 
        Import-Module ActiveDirectory -ErrorAction Stop #checks if active directory powershell module installed.
    } 
    Catch 
    { 
       Write-Warning $_ 
       Break 
    } 
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
            Write-host $_.MachineName
        }#end ifevent 
    }#end foreach lockedout event
    Write-Verbose "Collected Details Update in the Text File. Please find the Text file for More Details"
    if ((Get-ADUser $username -Properties * | Select-Object LockedOut) -match "True" )
    {
        switch ($unlockaccount)
        {
            ask
            {
                Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                Write-Host "$username is still locked out. Would you like to unlock the account now?"
                $unlock = Read-Host "[Y]/N Yes is defaulted: "
                if(!($unlock -eq "N"))
                {
                    try
                    {
                        Write-Host "Attempting to unlock AD account remotely..."
                        Unlock-ADAccount -Identity $username
                        Write-Host "User account Unlocked."
                    
                    }
                    catch
                    {
                        Write-host "error, $_"
                    }
                }
                else
                {
                    Write-Host "Input was No, user account has been left locked!"
                }
            }
            yes
            {
                Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                try
                {
                    Write-Host "Attempting to unlock"
                    Unlock-ADAccount -Identity $username
                    Write-Host "User account Unlocked."
                }
                catch
                {
                    Write-host "error, $_"
                }
            }
            no
            {
                Write-Host "Variable set to not unlock users automatically! Can be changed on line 6!"
            }
            default
            {
                Write-Host "Error, User locked out but input was undefined in code. $unlockaccount <-- Not a valid input."
            }
        }
    }
    $runagain = Read-Host "Do you want to run it again?"
    $runagain = $runagain.ToString().ToLower()
    if($runagain -like "y")
    {
        $runagain = $true
    }
    elseif($runagain -like "yes")
    {
        $runagain = $true
    }
    else
    {
        $runagain = $false
        $nul = Read-Host "Not running again. Press any key to close."
    }
} 

