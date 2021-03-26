<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. If you want it exported as a text file, Uncomment the Add-Content $home\Desktop... and update as needed.
    
    Notes:
        Checks if volumes are encrypted and lists any that aren't

#>

$getworkspaces = Get-WKSWorkspaces
foreach($workspace in $getworkspaces)
{
    if(($workspace.RootVolumeEncryptionEnabled -like "False") -or ($workspace.UserVolumeEncryptionEnabled -like "False"))
    {
        Write-Host "The workspace of*"$workspace.UserName"*is not encrypted"
        #Add-Content $home\desktop\UnEncrypted Workspaces.txt $workspace.WorkspaceId
        #uncomment the above line to export the list of Workspace ID's to your desktop. 
    }
}

