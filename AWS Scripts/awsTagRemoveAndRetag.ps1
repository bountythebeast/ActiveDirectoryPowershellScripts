<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $listofservers with input list. 
            Format: WorkspaceID,NEW tag Value
        2. Update $logfile
        3. Update $DeliminatingChar if using something other than a camma.

    Notes:
        This will remove the old Tag Entirely, then add the tag back with the new value.
        This was more consistant then attempting to update the value and was easier to verify. 

#>

$Tag = New-Object Amazon.WorkSpaces.Model.Tag

$listofservers = gc $home\Desktop\TagFix.txt
$DeliminatingChar = ","
$tag.Key = "Primary Tag"

$logfile = "$home\Desktop\awsTagFixer.log.txt"

Foreach($server in $listofservers)
{
    $workspaceID = $server.Substring(0,$server.IndexOf($DeliminatingChar))
    $tag.Value = $server.Substring($server.IndexOf($DeliminatingChar)+1)

    try
    {
        Remove-WKSTag -ResourceId $workspaceID -TagKey $tag.Key -Force
        Add-Content $logfile "$workspaceID,tag removed."
        $tagremoved = $true
    }
    catch
    {
        $errormessage = $_.Exception.Message
        Write-Host "$workspaceID,  failed because: $errormessage"
        Add-Content $logfile "$workspaceID,Failed: $_.Exception.Message"
        $tagremoved = $false
    }
    if($tagremoved -eq $true)
    {
        New-WKSTag -WorkspaceId $workspaceID -Tag $tag -Force
        Add-Content $logfile "$workspaceID,Tag updated successfully."
    }
    else
    {
        Write-Host "Error, $_.Exception.Message"
        Add-Content $logfile "$workspaceID,Failed: $_.Exception.Message"
    }
}

