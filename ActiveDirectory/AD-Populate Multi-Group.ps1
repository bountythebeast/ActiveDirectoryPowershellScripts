<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update the $inputfile with your input file location
        2. Update the input.txt with your data 
            Format: group;UserID (Used a semi Colon ';' delimiter. If your using a different one, update $group and $user accordingly.)
    
    Notes:
        Designed to add users to groups in mass.
        Requires AD Modify Permission. 
        
#>

$inputfile = gc $home\desktop\input.txt

foreach($user in $inputfile)
{
    $group = $user.substring(0,$user.indexof(";"))
    $user = $user.substring($user.indexof(";")+1)
    Add-ADGroupMember -Identity $group -Members $user
}