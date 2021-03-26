<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $input 1 IP per line.
        2. Update $output
    
    Notes:
        Returns a ping -a command for each IP. Powershell uses Resolve-DnsName Module for this.

#>


Remove-Variable * -ErrorAction SilentlyContinue
$input = gc $home\Desktop\input.txt
$output = "$home\desktop\ping-a.csv"
$previous = $Null
$total = $input.count

$ErrorActionPreference = $SilentlyContinue

foreach($IP in $input)
{
    $count++
    $isWritten = $false
    write-host "$count/$total"
    if($previous -ne $IP)
    {
        $temp = Resolve-DnsName -Name $IP -DnsOnly
    }
    $HostName = $temp.NameHost
    do
    {
        try
        {
            add-content $output "$IP,$HostName" -ErrorAction Stop
            $isWritten = $true
        }
        Catch
        {write-host "I/O issues, trying again."}
    } until ($isWritten)
    $previous = $IP
}