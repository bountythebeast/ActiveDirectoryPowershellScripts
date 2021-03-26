<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $Listofshares - 1 per line.
            Format: \\server\drive$\path OR \\server\share
        2. Update $output - Default format- CSV

    
    Notes:
        

#>

$Listofshares = gc $home\desktop\input.txt
$output = "$home\Desktop\output.csv"

add-content $output "ShareName,Current Share Size(GB),Free Drive Space(GB), Drive Total Size(GB),Notes"
foreach($share in $Listofshares)
{
    if($share -like "\\*")
    {
        try
        {
            $servername = ($share.substring(2))
            $sharename = ($servername.Substring($servername.IndexOf("\")+1))
            $servername = $servername.substring(0,$servername.indexof("\"))
            $sharesnamepath = get-wmiobject -Class Win32_Share -ComputerName $servername | Where Type -NotMatch '21474836\d{2}' | select Name,Path
            $sharepath = (($sharesnamepath | Where {$_.Name -eq $sharename}).path).Replace('$',':')
            $sharedriveletter = ($sharepath.substring(0,2))
            $shareusage = "{0:N0}MB" -f ((gci $share | measure Length -s).Sum /1MB)
            $drive = (get-wmiobject -Class Win32_logicaldisk -Filter "DeviceID = '$sharedriveletter'" -ComputerName $servername | Select FreeSpace,Size)
        
            $drivefreespace = (([math]::round($drive.FreeSpace/1MB, 0)).ToString()+ "MB")
            $drivespace = (([math]::round($drive.Size/1MB, 0)).ToString() + "MB")

            sleep -Milliseconds 300
            add-content $output "$share,$shareusage,$drivefreespace,$drivespace"
        }
        catch
        {
            sleep -Milliseconds 300
            add-content $output "$share,$shareusage,$drivefreespace,$drivespace,Exception/Failed."

        }

        $servername = $null;$sharename = $null;$sharesnamepath = $null;$sharepath = $Null;$sharedriveletter = $Null;
        $shareusage = $null; $shareusage = $Null;$drive = $Null;$drivefreespace  = $Null; $drivespace = $Null;
    }
    else
    {
        sleep -Milliseconds 300
        add-content $output "$share,Invalid share path"
    }
}