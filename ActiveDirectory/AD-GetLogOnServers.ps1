<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $input to your input folder. Update the text file with Active Directory UserID's, 1 per line.
        2. Set the $output, current export type is CSV for ease of use.
        3. Run.
    
    Notes:
        This script was designed to export the LogonWorkstations field primarily for service accounts.
        If there are no servers specified with explicit rights, it returns "All Servers" as that is how Active Directory works. 
        
#>


$input = gc $home\Desktop\input.txt
$output = "$home\Desktop\output.csv"

foreach($account in $input)
{
    $logoninfo = get-aduser $account -Properties * | Select-Object -ExpandProperty LogonWorkstations
    if($logoninfo)
    {
        $logoninfo | add-content $output
    }
    else
    {
        Add-Content $output "All Servers"
    }
}
