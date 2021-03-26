<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $listofallservers - 1 per line.
    
    Notes:
        Designed to export to console. Ideal for small query's, not designed for bulk export.

#>



<#
    Share Info & NTFS Permissions

    Description:
        Goes to each server in $listofallservers and pulls the share permissions and NTFS permissions 
            (excluding NT Auth, BuiltinAdmin and Creator Owner to cut down on static)

    Notes:
    Writes to console due to issues with exporting mutliple servers with formatting. 

#>
$listofallservers = gc $home\desktop\list.txt

foreach ($server in $listofallservers)
{
    $sharesnamepath = get-wmiobject -Class Win32_Share -ComputerName $server | Where Type -NotMatch '21474836\d{2}' | select Name,Path
    foreach($share in $sharesnamepath)
    {
        $sharename = $share | Select-Object -ExpandProperty Name
        $sharepath = $share | Select-Object -ExpandProperty Path
        $driveletter = $sharepath.Substring(0,2)
        if(!($sharepath -like "*$*"))
        {
            $diskname = get-wmiobject -Class Win32_logicaldisk -Filter "DeviceID = '$driveletter'" -ComputerName $server | Select-Object -ExpandProperty VolumeName
            if($diskname -notlike "*Y Drive*")
            {
                $users = $null
                $sharepathvar = $sharepath
                $sharepathvar = $sharepathvar.Replace(':','$')
                $identityreference = get-acl "\\$server\$sharepathvar" | select -Expand Access | % {$_.IdentityReference}
                foreach($entry in $identityreference)
                {
                    if(!(($entry -like "*NT Authority*") -or ($entry -like "*BUILTIN*") -or ($entry -like "*CREATOR OWNER*")))
                    {
                        $users += "$entry;"
                    }
                }
                Write-host "~~~~~~~~~~~~~~~~~~ $server ~~~~~~~~~~~~~~~~~~"
                Write-host "Share information:"
                Write-host "$server;$sharepath;$sharename"
                Write-host "NTFS:"
                get-acl -LiteralPath "\\$server\$sharepathvar" | format-table -wrap
                Write-host "AD Shares/users"
                Write-host "$users"
                Write-host "~~~~~~~~~~~~~~~~~~ end $server ~~~~~~~~~~~~~~~~~~"
            }
        }
    }
    
}