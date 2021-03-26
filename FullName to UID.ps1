<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $users as needed. Full Names, 1 per line.
        2. Run Script.
    
    Notes:
        A simple script designed to take full names and convert them to UserIDs.

#>


$users = gc $home\desktop\fullname.txt


foreach($user in $users)
{
    $adout = get-aduser -Filter{displayName -like $user} -Properties * | Select-Object Name,SamAccountName
    $name = $adout.Name
    $uid = $adout.SamAccountName   

    Add-Content $home\desktop\output.txt "$name - $uid"
}