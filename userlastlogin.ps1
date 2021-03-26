<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $userlist - 1 UserID per line
        2. Update $output
    
    Notes:
        Retrieves their last Logon Date timestamp from AD.

#>

$userlist = gc $home\desktop\usernames.txt
foreach ($username in $userlist)
{
    $lastlogindate = get-aduser -Identity $username -Properties "LastLogonDate"| select-object -ExpandProperty "LastLogonDate"
    if($lastlogindate -eq $null)
    {$lastlogin = "N/A"}
    else
    {$lastlogin = $lastlogindate.ToString('MM-dd-yy')}
    $output = "$username,$lastlogin"
    Add-Content $home\desktop\userlastlogin.txt $output
    
    
    $output = $null,$lastlogindate = $null,$lastlogin = $null

}
