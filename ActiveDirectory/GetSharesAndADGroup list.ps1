<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $listofallservers - 1 per line.
        2. Update $output
        3. Update $domain - Must have a \. This allows the script to more accurately expand groups.
    
    Notes:
        A basic share export.

#>

$listofallservers = gc $home\desktop\serverlist.txt
$output = "$home\desktop\output.txt"
$domain = "example\"

### Detect the 'name' of the drive, and if its like Y drives, don't include it! 


foreach ($server in $listofallservers)
{
    sleep -Milliseconds 100
    Add-Content $output "Currently Working on $server"
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
                $datetime = (get-date)
                sleep -Milliseconds 100
                Add-Content $output "$server\$sharepathvar"# this was added on ut datetime is not needed. - $datetime"
                if(!(($entry -like "*NT Authority*") -or ($entry -like "*BUILTIN*") -or ($entry -like "*CREATOR OWNER*")))
                {
                    sleep -Milliseconds 100
                    add-content $output "- $entry"
                    if(($entry -like "* *") -or ($entry -like "*-*"))
                    {
                        $entry = $entry.ToString()
                        if($entry -like "$domain*")
                        {

                            $entry = $entry.Substring($domain.length)                  
                        }   
                        $adgroupusers = $null
                        $adgroupusers = get-adgroupmember $entry | select -ExpandProperty name
                        if($adgroupusers -like $null)
                        {
                            $allusers = "None found."
                        }
                        else
                        {
                            $allusers = $null
                            foreach($adgroupuser in $adgroupusers)
                            {
                                $allusers+="$adgroupuser;"
                            }
                        }
                        sleep -Milliseconds 100
                        Add-Content $output " > $allusers"
                    }
                }
            }
        }
    }
}

##add a progress bar...