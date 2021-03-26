<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update the $grouplist with a list of Groups you want to move.
        2. Update the Move-ADObject... -TargetPath "" with the EXACT path you want the groups moved too. 
    
    Notes:
        Names are explicit. A wildcard can be used, but is NOT recommended for obvious reasons.

#>

$grouplist = gc $home\desktop\groups.txt
#$grouplist = "Group1",""

foreach($group in $grouplist)
{
    $guid = Get-ADObject -filter 'Name -like $group'
    $guid = $guid.ObjectGUID

    Move-ADObject -Identity $guid -TargetPath "OU=OU,OU=OU,DC=Domain,DC=net"
}
