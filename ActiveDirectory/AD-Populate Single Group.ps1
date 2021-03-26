<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update the $inputfile with your location
        2. Update the input.txt file with a list of UserID's (or computer objects, Must have a $ or it will FAIL!).
        3. Update the $group = "" with the group you want the list added too.
    
    Notes:
        Ideal for bulk adding of users/computer objects to a single group.
        
#>

$inputfile = gc $home\desktop\input.txt 
$group = "AD Group"


foreach($user in $inputfile)
{
    Add-ADGroupMember -Identity $group -Members $user
}