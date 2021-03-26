<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $grouplist input as needed, 1 group per line.
        2. Update $outputfile as needed. Default format is CSV.
    
    Notes:
        $ErrorActionPreference is set to Inquire, this can be set to SilentlyContinue if there are errors.
        
        This script contains a Looping Function.
            > This means, it will expand every AD Group until it has displayed every user.

        For a single Group, You can use the following.
            $group = "AD Group"
            get-adgroupmember $group | select -ExpandProperty name

#>


$grouplist = gc $home\desktop\list.txt
$outputfile = "$home\desktop\output.csv"

$ErrorActionPreference= "Inquire"
#Setting up functions for looping.
function Get-ADGroupMembersFunction 
{
    $space = ""
    $outputfile = $args[0]
    $person = $args[1]
    if(($args[2] -ge 1) -and ($args[2] -notlike $null))
    {
        $count = $args[2]
    }
    else
    {
        $count = 0
    }
    $spacer = "-> ";$space = ""
    if($count -ne 0)
    {
        for($i=0;$i -lt $count;$i++)
        {
            $space +=$spacer
        }
    }

    if($person -ne $null)
    {
        if(get-ADUser -Filter {SAMAccountName -eq $person})
        {
            #is user;export data.
            $adquerry = get-aduser $person -Properties * | select SamAccountName,DisplayName,Department
            $content =($adquerry.SamAccountName+";"+$adquerry.DisplayName+";"+$adquerry.Department)
            $content = $space + $content
            sleep -Milliseconds 100
            Add-Content $outputfile $content
        }
        else
        {
            #is group... run nesting.
            $tempvar = $space + $person
            sleep -Milliseconds 100
            add-content $outputfile $tempvar
            if($person -like "*$*")
            {
                $content = "$person;Server/Service Account!"
                $content = $space + $content
                sleep -Milliseconds 100
                Add-Content $outputfile $content
            }
            else
            {
                $nestedgroup = get-adgroupmember $person | select -ExpandProperty SAMAccountName
                $count++
                if($nestedgroup.count -gt 1)
                {
                    foreach($nesteduser in $nestedgroup)
                    {
                        Get-ADGroupMembersFunction $outputfile $nesteduser $count
                    }
                }
                else
                {
                    Get-ADGroupMembersFunction $outputfile $nestedgroup $count
                }
            }

        }
    }
}


foreach($group in $grouplist)
{
    if($group -like "*$*")
    {
        Write-host "[WARNING] $group! This is not a group; its a Server! (contains a $) Skipped!"
    }
    elseif($group -like "*@*")
    {
        Write-host "[@Delimiter] writing line $group"
        add-content $outputfile $group
    }
    elseif(get-aduser -filter {SAMAccountName -eq $group})
    {
        Write-host "[WARNING] $group! This is not a group; its a User! (SAMAccountname Check failed) Skipped!"
    }
    else
    {
        sleep -Milliseconds 100
        add-content $outputfile "~~~~~ $group ~~~~~"
        $user = get-adgroupmember $group | select -ExpandProperty SAMAccountName
        if($user.count -gt 1)
        {
            #add logic for user vs group vs server?
            foreach($person in $user) #more than 1; foreach entry in the $user of $group
            {
                Get-ADGroupMembersFunction $outputfile $person
            }
        }
        else
        {
            Get-ADGroupMembersFunction $outputfile $user
        
        } 
        sleep -Milliseconds 100
        add-content $outputfile  "~~~~~ $group ~~~~~"
        sleep -Milliseconds 100
        add-content $outputfile  " "
    }
}