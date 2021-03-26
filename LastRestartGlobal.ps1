<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $days. Any server that has not been restarted in >$days, will be displayed.
    
    Notes:
        

#>

$days = 90

$serverlist = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} | select -ExpandProperty Name

Write-host "Computers that have not been restarting in $days or greater:"
$ErrorActionPreference = "SilentlyContinue"
$total = $serverlist.count
$count = 0
foreach($server in $serverlist)
{
    if(Test-Connection $server)
    {
        $count++
        $invoke = invoke-command -ComputerName $server -ScriptBlock `
        {
            $system = Get-WmiObject win32_operatingsystem

            if($system.ConvertToDateTime($system.LastBootUpTime) -lt (Get-Date).AddDays(-$args[0]))
            {
                return $true
            }
        } -ArgumentList $days
        if($invoke -eq $true)
        {
            write-host $server
        }
    }
    #Write-host "Working on $count/$total"
}

