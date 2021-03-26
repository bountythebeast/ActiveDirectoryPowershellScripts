<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $accountlist as needed. 1 Service Account per line.
        2. Run script.
    Notes:
        This script is designed to set the ScriptPath of accounts. 
        
        logoff.bat is a default windows system execution that upon attempting an RDP session, will immediately trigger a logoff of the account. 

#>

Import-module ActiveDirectory
$accountlist = gc $home\desktop\serviceaccountsfix.txt

foreach($adaccount in $accountlist)
{
    Get-ADUser -Identity $adaccount | Set-ADUser -ScriptPath "logoff.bat"
}