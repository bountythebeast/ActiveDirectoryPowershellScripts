<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $multiple if you want only specific accounts.
        2. Update $list with your input list. 1 UserID per line.
        3. Update Get-ADUser... -SearchBase to the OU you want.
    
    Notes:
        

#>

$multiple = $false

if($multiple -eq $false)
{
    Get-ADUser -Filter * -Properties scriptpath,LastLogonDate | ft Name, scriptpath,LastLogonDate > $home\desktop\output.txt
    
}
else
{
    $list = gc $home\desktop\servicelist.txt
    foreach ($name in $list)
    {
        Get-ADUser -Filter {Name -eq "$name"} -SearchBase "OU=Service Accounts,DC=Domain,DC=net" -Properties scriptpath,LastLogonDate | ft Name, scriptpath,LastLogonDate > output.txt
    }
}
