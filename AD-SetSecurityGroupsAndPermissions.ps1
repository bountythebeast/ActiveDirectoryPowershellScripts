<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Should NOT be run within the first few minutes of the AD Groups being created. This is because of DC Replication time. 
        2. Update the $GroupNames as needed.

    Notes:
        Default input format: Server-Share-RO/RW
        
#>

#$GroupNames = "Server-Share-RW"
$GroupNames = gc "$home\Desktop\Grouplist.txt"


#~~~~~~~~~~~~~~~ Nothing Below This line should be touched ~~~~~~~~~~~~~~~#
#Static Variables, only need to be set once. 
$Date = Get-Date -format d
#Sets the Policy flags
$readOnly = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute"
$readWrite = [System.Security.AccessControl.FileSystemRights]"Modify"
$inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$propagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$type = [System.Security.AccessControl.AccessControlType]::Allow

#Dynamic code, needs to be repeated every cycle. 
foreach ($GroupName in $Groupnames)
{
    #grabs the server name, and the share name and sets them to $server and $name
    $server = $GroupName.Substring(0,($GroupName.IndexOf("-")))
    $name = $GroupName.Substring($GroupName.IndexOf("-")+1)   
    $name = $name.Substring(0,$name.indexof("-"))   

    #gets the path of the share (full)
    $path = get-wmiObject -class Win32_Share -computer $Server | where -property name -eq $name | select -expandproperty Path -first 1
    #seperates the letter of the share
    $letter = $path.Substring(0,$path.IndexOf("\")-1)  
    #removes the 'fluff' and fixes path to \\servername\letter$\share location
    $path = $path.Substring($path.IndexOf(":")+1)
    $path = "\\$server\$letter$"+"$path"



    #Finds existing access privledges.
    $acl = (Get-Item $path).GetAccessControl('Access')

    #next, run decide if you want RW or RO

    #Read Write
    if ($GroupName -Like '*RW*')
    {
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupName,'Modify','ContainerInherit,ObjectInherit','None','Allow')
        $acl.SetAccessRule($Ar)
        set-acl -path $path -AclObject $acl
        write-host "Read-Write Group Created. $groupName"
    }

    #Read Only
    if ($GroupName -Like '*RO*')
    {
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupName,'ReadAndExecute','ContainerInherit,ObjectInherit','None','Allow')
        $acl.SetAccessRule($Ar)
        set-acl -path $path -AclObject $acl
        Write-Host "Read-Only Group Created. $GroupName"
    }
}