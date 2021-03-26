<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $listofallservers - 1 server per line
        2. Update $outputdatafile
    
    Notes:
        Gets a list of shares and the groups that have rights to them. This is the simplified version.
        

#>

$listofallservers = gc $home\desktop\serverlist.txt
$outputdatafile = "$home\desktop\listofshares.txt"





Set-Content $outputdatafile "Server;drive/path;sharename;access;access;access;access;access;access;access;access;access;access"
foreach ($server in $listofallservers)
{
    Write-Host "Currently working on $server"
    $sharesnamepath = get-wmiobject -Class Win32_Share -ComputerName $server | Where Type -NotMatch '21474836\d{2}' | select Name,Path
    foreach($share in $sharesnamepath)
    {
        $sharename = $share | Select-Object -ExpandProperty Name
        $sharepath = $share | Select-Object -ExpandProperty Path
        $driveletter = $sharepath.Substring(0,2)
        if(!($sharepath -like "*$*"))
        {
            $diskname = get-wmiobject -Class Win32_logicaldisk -Filter "DeviceID = '$driveletter'" -ComputerName $server | Select-Object -ExpandProperty VolumeName
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
            Add-Content $outputdatafile "$server;$sharepath;$sharename;$users"
        }
    } 
}

##add a progress bar...