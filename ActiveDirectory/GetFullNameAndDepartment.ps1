<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $userlist - 1 UserID per line.
        2. Update $outfile
    
    Notes:
        Export the UserID, Full name, Department and Company from Active Directory.

#>




$userlist = gc $home\Desktop\UID.txt
$output = $null
$outfile = "$home\Desktop\output.txt"
foreach($user in $userlist)
{
    $output = $null
    try
    {
        #query AD for full name; and department.
        $fullname = (Get-ADUser $user -Properties DisplayName).DisplayName
        $Department = (Get-ADUser $user -Properties Department).Department
        $CompanyBranch = (Get-ADUser $user -Properties Company).Company
        Add-Content $outfile ($user + "," + $fullname + "," + $Department + "," + $CompanyBranch)
    }
    catch
    {
        Add-Content $outfile "$user failed to be determined; reason: $_.Exception.Message"
    }
}

