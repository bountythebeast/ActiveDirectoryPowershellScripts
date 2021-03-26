<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $query as needed.
        2. Update add-content... as needed.
    
    Notes:
        Designed to export a list of Windows Server systems from AD. Originally created to obtain a full fresh server list to be used with bulk scripts or query's. 

#>


$query = (Get-ADComputer -Filter {enabled -eq "true" -and OperatingSystem -Like '*Windows Server*'}).Name

foreach($line in $query)
{
    add-content "$home\desktop\serverlist.txt" $line
}