<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $uid with the respective input file. 1 UserID per line.
        2. Update $output with the desired output location.
        3. Run.
    
    Notes:
        Output can be updated to export a CSV, but was designed to export as a semicolon delimited flat text file. This can be imported into excel using Data -> From Text -> semicolon delimited.

#>

$uid = gc $home\Desktop\UID.txt
$output = "$home\desktop\outputfile.txt"
$total = $uid.count;$count = 0
foreach ($user in $uid)
{
    $count++
    write-host "$count/$total"
    if(!($user -like $userdata))
    {
        try{$userdata = Get-ADUser $user -Properties *}
        catch{$userdata.Department = "failed"}
    }
    $department = $userdata.Department
    Add-Content $output "$user;$department"
}