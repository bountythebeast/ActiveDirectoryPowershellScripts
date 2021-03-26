<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $lastofservers as needed.
            Format: WorkspaceID,Tag Value
        2. Update $DeliminatingChar as needed if not using a camma.
        3. Update $tag.Key. This is the PRIMARY KEY such as Name. 
    
    Notes:
         Your Workspace id should be ws-(id) format!

         This will ADD a tag to all workspaces.

#>


##### These are the values designed to be modified by *you* #####
$listofservers = gc $home\Desktop\tagthese.txt #where it looks for a file. $home\ is your user profile, thus $home\Desktop is your desktop. 
$DeliminatingChar = "," #defaulted to Camma
$tag.Key = "Primary Key"
##### These are the values designed to be modified by *you* #####



#################################################################
##        Nothing below this line should be modified!          ##
#################################################################


$workspaceID = $null #nulling $workspace id to ensure it is populated correctly. This allows if check before attempting to create a tag on a null server and throwing a lot of errors.

#for each entry
foreach($server in $listofservers)
{
    $workspaceID = $server.Substring(0,$server.IndexOf($DeliminatingChar))
    $tag.Value = $server.Substring($server.IndexOf($DeliminatingChar)+1)

    
    if($workspaceID -ne $null)
    {
        try
        {
            New-WKSTag -WorkspaceId $workspaceID -Tag $tag -Force
            Write-Host "Workspace: $workspaceID set Successfully"
        }
        Catch
        {
            Write-Host "Error, $_.Exception.Message"
        }
    }
}

