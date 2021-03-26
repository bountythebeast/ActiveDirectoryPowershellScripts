<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Run Script
        2. Follow in script prompts as needed. 
    
    Notes:
        The script will query the entire AD system for a list of all locked out users.
        
        After the list is displayed, it will give you the option to unlock none of them (default), Some (yes) or all (all).
#>

$lockedout = Search-ADAccount -LockedOut | select -ExpandProperty Name
Write-Host "Current list of locked out users: "
$lockedout

$input = Read-Host "Would you like to unlock any of these accounts? Please enter a Y, N or A [Yes, No, All, default will be No.]"

if($input -like "y" -or $input -like "yes")
{
    Search-ADAccount -LockedOut | Unlock-ADAccount -Confirm
}
elseif($input -like "a" -or $input -like "all")
{
    Search-ADAccount -LockedOut | Unlock-ADAccount
}
else
{
    Write-Host "No AD-Accounts unlocked; Exiting!"
    exit
}