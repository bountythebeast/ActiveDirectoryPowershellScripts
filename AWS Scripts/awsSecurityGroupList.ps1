<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Run.
    
    Notes:
        List all security groups that are not REQUIRED by AWS.

#>

$ec2sg = (get-ec2securitygroup)
$groupnames = ((Get-EC2NetworkInterface | select -ExpandProperty Groups) | select -ExpandProperty GroupName) | sort -Unique #gets unique groups in use...

$hideAWSgroups = $false

$count = 0
###################### DO NOT LIST _controllers!!! THESE ARE DIRECTORY CONTROLLERS AND ARE REQUIRED! Deleting these could potentially break EVERYTHING ######################
foreach($group in $ec2sg)
{
    if($hideAWSgroups -eq $false)
    {
        $group | % {$current = ($_.Tags) } 
        $SGname = ($current | ? {$_.key -eq "name"} | select -expand Value )
        $SGid = $group.GroupId
        $SGgroupname = $group.GroupName
        $acls = ($group | % { $_.IpPermissions} | Select -Property IpProtocol, ToPort, IpRanges)
        $group | % { $_.IpPermissions} | Select -Property IpProtocol, ToPort, IpRanges

        
       
        write-host ($groupnames[$count]+" "+$SGid)
        write-host ($acls | Out-String)
      
        $count++
    }
    else
    {
        $group | % {$current = ($_.Tags) } 
        $SGname = ($current | ? {$_.key -eq "name"} | select -expand Value )
        $SGid = $group.GroupId
        $SGgroupname = $group.GroupName
        $acls = ($group | % { $_.IpPermissions} | Select -Property IpProtocol, ToPort, IpRanges)
        $group | % { $_.IpPermissions} | Select -Property IpProtocol, ToPort, IpRanges


        if(!(($groupnames[$count] -like "*workspaceMembers*") -or ($groupnames[$count] -like "*controllers*")))
        {
            
            write-host ($groupnames[$count]+" "+$SGid)
            write-host ($acls | Out-String)
        }
        $count++
    }
}

