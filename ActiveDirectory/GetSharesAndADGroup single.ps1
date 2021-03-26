<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $server
        2. Update $domain
    
    Notes:
        This is a ShareInformation single server. It outputs to the console.

#>


$server = "servername"
$domain = "example\"

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
            write-host "$server\$sharepathvar - $datetime"
            Write-Host "- $entry"
            if(($entry -like "* *") -or ($entry -like "*-*"))
            {
                $entry = $entry.ToString()
                if($entry -like "$domain*")
                {

                    $entry = $entry.Substring($domain.length)                  
                }   
                $adgroupusers = $null

                $adgroupusers = get-adgroupmember $entry | select -ExpandProperty name
                if(($adgroupusers -like $null) -or ($adgroupusers -like " "))
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
                write-host " > $allusers"
            }
        }
        $datetime = (get-date)
    }
}

##add a progress bar...