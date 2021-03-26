<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $GroupNames either using a camma delimiter, or to accept fileshare input.
        2. Update the signature/Requested by fields, and the $OU as needed or per your needs.
        3. Run script. 
    
    Notes:
        This was designed for mass creation of AD Groups. 

        This was not designed for setting share permissions, or other activies of that nature.
        
#>


$OU = "OU=Security Groups,DC=domain,DC=net"
#$OU = "OU=File Share Groups,OU=Security Groups,DC=domain,DC=net"
#$OU = "OU=Groups,OU=Secured,DC=domain,DC=net"


#~~~Please use the input format of Server-Share-RO/RW~~~#

#~~~Pull from a list called Grouplist.txt on desktop~~~#
#$GroupNames = "Server-Share-RO"
#$GroupNames = gc "$home\Desktop\Grouplist.txt"
$GroupNames = "Group1,Group2,Group3"

#~~~ Change below as needed ~~~#
$userSignature = ""
$RequestedBy = ""

#~~~Change to $true When ready to Modify AD~~~#
$modifyad = $true
#$modifyad = $false

#~~~~~~~~~~ Nothing Below This line should be touched ~~~~~~~~~~#
$Date = Get-Date -format d

$Notes = "$UserSignature - $Date - Requested by: $RequestedBy"
Write-Host $OU


foreach ($GroupName in $Groupnames){


$Description = $GroupName

#~~~Test Parameter, Recommended to leave uncommented.~~~#
Write-Host $Notes
Write-Host $Description


#~~~AD Parameter!~~~#
if ($modifyad -eq $true){
New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupCategory Security -GroupScope Global -DisplayName $GroupName -Path "$OU" -Description $Description -OtherAttributes @{info=$Notes}
Write-Host "AD Modified"}
if ($modifyad -eq $false){
Write-Host "AD NOT modified. To modify, Comment modifyad false, and uncomment true." -ForegroundColor Red}

#~~~AD Parameter!~~~#

} 

$GroupNames = $null