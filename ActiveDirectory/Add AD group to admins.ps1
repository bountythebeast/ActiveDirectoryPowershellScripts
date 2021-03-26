<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Change the $DomainGroup to the User/Group you want added to the Local Admin Group (LAG).
        2. Change the $LocalGroup if you want to modify a different group
        3. Update the $Domain with your Domain (and a '\' as it is required.)
        4. Update the $GroupNames with either a single server, or list of servers.
        5. Run script!
    
    Notes:
        Requires existing Admin or equivilent rights on every server you are attempting to execute this against. 
        
#>


### Change the $DomainGroup to the User###
### Adds $DomainGroup to the Administrators group on Systems located in $GroupNames ###

$DomainGroup = "Domain Group"
$LocalGroup  = "Administrators"
$Domain      = "Domain\"

$GroupNames = gc "$home\Desktop\Servers.txt"
#or
#$GroupNames = "Server",""# - Single server. ## There is a ,"" following the servername. This is intentional as the below foreach would break if that was not there. 
$ErrorActionPreference = 'SilentlyContinue'
foreach ($Server in $GroupNames)
{
    ([ADSI]"WinNT://$Server/$LocalGroup,group").psbase.Invoke("Add",([ADSI]"WinNT://$Domain/$DomainGroup").path)
    Write-Host "$DomainGroup added to $Server $LocalGroup group"
}