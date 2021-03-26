<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Create a file on your Desktop (default) called Grouplist.txt
            > This can be modified to a single AD-Group, or a lot by modifying $GroupNames
        2. If you want to have the script 'check' to make sure everything works but not modify AD, you can flip the $modifyad to $false.
        3. Run script. 
    
    Notes:
        This script was heavily influenced by how our environment was set up, and its requirements. Some things will obviously need to be modified for your environment.
        
        This script *WILL* attach the AD Group to the share with Read-Only or Read-Write permissions if using the example format below, or similar. 

        "$home\" is a shortcut built into powershell for your user profile desktop. If you are using a non C:\users\your-user\ as your path, you will need to update this.
#>



#~~~Please use the input format of Server-Share-RO/RW~~~#

#~~~Pull from a list called Grouplist.txt on desktop~~~#
#$GroupNames = "server-share-RO"
$GroupNames = gc "$home\Desktop\Grouplist.txt"

#~~~ Change below as needed ~~~#
$userSignature = ""
$RequestedBy = ""

#~~~Change to $true When ready to Modify AD~~~#
$modifyad = $true
#$modifyad = $false


#~~~~~~~~~~ Nothing Below This line should be touched ~~~~~~~~~~#
$Date = Get-Date -format d

#$OU = "OU=Security Groups,DC=domain,DC=net" #Non File Share
$OU = "OU=File Share Groups,OU=Security Groups,DC=domain,DC=net"

$Notes = "$UserSignature - $Date - Requested by: $RequestedBy"

foreach ($GroupName in $Groupnames){

#~~~Gets the name of the share, between the -'s~~~#
$name = $GroupName.Substring($GroupName.IndexOf("-")+1)   
$name = $name.Substring(0,$name.indexof("-"))             
#$name = $GroupName

#~~~Gets server name~~~#
$server = $GroupName.Substring(0,($GroupName.IndexOf("-")))

#~~~Detects if its RW or RO~~~#
if ($GroupName –Like ‘*RW*’){
$Description = "This group has Read\Write access to \\$server\$name" }
elseif ($GroupName –Like ‘*RO*’) {
$Description = "This group has Read Only access to \\$server\$name"}
else
{$Description = "This group has access to \\$server"}

#~~~Test Parameter, Recommended to leave uncommented.~~~#
Write-Host $Notes
Write-Host $Description


#~~~AD Parameter!~~~#
if ($modifyad -eq $true){
New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupCategory Security -GroupScope Global -DisplayName $GroupName -Path $OU -Description $Description -OtherAttributes @{info=$Notes}
Write-Host "AD Modified"}
if ($modifyad -eq $false){
Write-Host "AD NOT modified. To modify, Comment modifyad false, and uncomment true." -ForegroundColor Red}

#~~~AD Parameter!~~~#

} 
$GroupNames = $null