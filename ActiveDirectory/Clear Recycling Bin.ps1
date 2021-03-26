<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $GroupNames with input file. 1 computer per line.
    
    Notes:
        This will clear the recycling bin of servers. Ideal for cleaning disk space.

#>

$GroupNames = gc "$PSScriptRoot\Clearlist.txt"

foreach ($GroupName in $Groupnames) #reads in from text file
{
    icm -ComputerName $GroupName -ScriptBlock {Clear-RecycleBin -Force -ErrorAction SilentlyContinue} #Clears the $Recycling.Bin for every user.
}

$stopnow = Read-Host -Prompt "Press any key to continue."