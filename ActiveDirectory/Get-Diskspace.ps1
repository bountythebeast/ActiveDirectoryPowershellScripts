<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $serverlist 1 server per line.
        2. Update $output
    
    Notes:
        This was a Disk space reporting tool we created to ensure servers had ample space. 

#>

$serverlist = gc $home\desktop\serverlist.txt
$output = "$home\desktop\output.txt"
foreach($server in $serverlist)
{
    write-host "~~~ $server ~~~"
    $disk = (Get-WmiObject Win32_LogicalDisk -ComputerName $server | Foreach-Object {
        if($_.Size/1GB -ge 1)
        {
            Write-host "Disk" $_.Name,($_.FreeSpace/1GB -as [int])"/",((($_.Size)-($_.FreeSpace))/1GB -as [int])"/",($_.Size/1GB -as [int])"GBs (Free/Used/Total)"
        }
    })
}