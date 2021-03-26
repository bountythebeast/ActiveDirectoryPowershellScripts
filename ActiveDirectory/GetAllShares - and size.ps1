<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $listofallservers - 1 server per line. 
            1.1 Alternatively, uncomment the #$listofallservers line to have it pull a fresh list from AD.
        2. Update $outputdatafile
    
    Notes:
        This will go to each server in the list, and export a full list of its shares, size, and full admin path.

#>


$listofallservers = gc $home\desktop\serverlist.txt
#$listofallservers = get-adcomputer -Filter * | select-object -ExpandProperty Name
$outputdatafile = "$home\Desktop\listofshares.txt"


Set-Content $outputdatafile "Server;drive/path;sharename;Size;Owner;access;access;access;access;access;access;access;access;access;access"
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
            $size = "{0:N2} MB" -f ((gci "\\$server\$sharepathvar" | measure Length -s).Sum /1MB)
            
            $identityreference = get-acl "\\$server\$sharepathvar" | select -Expand Access | % {$_.IdentityReference}
            foreach($entry in $identityreference)
            {
                if(!(($entry -like "*NT Authority*") -or ($entry -like "*BUILTIN*") -or ($entry -like "*CREATOR OWNER*") -or ($entry -like "*APPLICATION PACKAGE*")))
                {
                    $entry = $entry.ToString()
                    if(!($entry.Length -lt 9))
                    {
                        if($entry -like "*everestre*")
                        {
                            $entry = $entry.substring(10)
                        }
                    
                        if($notes -like "* *")
                        {
                            $notes += " @ "
                        }
                        $notesinfo = Get-ADGroup -Identity $entry -properties info
                        $notesinfo = $notesinfo.info
                        $notes += $notesinfo -replace "`t|`n|`r"," "

                        $access += "$entry;"
                        $entry = $null
                    }

                }
            }#
            if(($notes.Length -lt 5) -or ($notes -eq $null))
            {
                $notes = "No Owner/Notes found..."
            }
            Add-Content $outputdatafile "$server;$sharepath;$sharename;$size;$notes;$access"
            $size = $null;$notes = $null;$access = $null;$notesinfo = $null
        }
    }
}

##add a progress bar...

