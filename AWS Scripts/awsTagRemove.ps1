<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $listofservers file. 1 workspaceID per line.
        2. Update $tag.Key = "" This is the Primary Tag key, for example: Name
        3. Update $logfile - This is just the output.

    Notes:
        This will remove the ENTIRE tag specified as AWS doesn't like tags without a value.

#>



$Tag = New-Object Amazon.WorkSpaces.Model.Tag

$listofservers = gc $home\Desktop\untag.txt
$tag.Key = "Tag Key"

$logfile = "$home\Desktop\awsTagFixer.log.txt"

Foreach($workspaceID in $listofservers)
{
    try
    {
        Remove-WKSTag -ResourceId $workspaceID -TagKey $tag.Key -Force
        Add-Content $logfile "$workspaceID,  tag removed."
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
        Add-Content $logfile "$workspaceID,Tag updated successfully."
    }
    else
    {
        Add-Content $logfile "$workspaceID,Failed: $_.Exception.Message"
    }
}

