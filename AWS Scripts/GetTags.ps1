<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update the $tag = Get-WKSTag... $_.Key -like "" with the primary key tag you want everything to have. For example, Creation date.

    Notes:
        If a workspace doesn't have the 'required' primary tag (see instruction 1.) it says 'Not Tagged!' otherwise, will dispaly tag in the output.

#>


$workspaceIDs = Get-WKSWorkspace | Select-Object -ExpandProperty WorkspaceId

foreach ($workspace in $workspaceIDs)
{
    $tag = new-object Amazon.EC2.Model.Tag
    $tag = Get-WKSTag -WorkspaceId $workspace | Where {$_.Key -like "Primary Tag"}
    $UID = Get-WKSWorkspace -WorkspaceID $workspace | Select-Object -ExpandProperty UserName
    $IP = Get-WKSWorkspace -WorkspaceID $workspace | Select-Object -ExpandProperty IpAddress
    if ($tag.Value -like $null)
    {
        $output = $workspace + ";" + $UID +";"+ "Not Tagged!" + ";" + $IP
    }
    else
    {
        $output = $workspace + ";" + $UID +";"+ $tag.Value + ";" + $IP
    }
    Add-Content $home\Desktop\temp.txt $output
    $tag = $null
}
