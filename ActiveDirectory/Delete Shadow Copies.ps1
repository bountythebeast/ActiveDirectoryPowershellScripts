<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $GroupNames with a list of servers. 1 per line.
    
    Notes:
        This clears shadow copies from servers that build up over time. A safe way to clear disk space in a rush.

#>

$GroupNames = gc "$PSScriptRoot\Clearlist.txt".

foreach ($GroupName in $Groupnames)
{
    $shadowCopies = Get-WMIObject -Class Win32_ShadowCopy -Computer $GroupName -ErrorAction SilentlyContinue
    $shadowCopies.Delete()               # Works when only a single shadow copy exists
}