<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Notes:
        This was originally a 1-off piece of code that came back a few times. It gets the employeeNumber field, the UserID and the Full name of every user.
        

#>


Get-ADUser -Filter * -Properties employeeNumber | Where 'enabled' -eq 'true' | Select EmployeeNumber,SamAccountName,UserPrincipalName | export-csv $home\desktop\output.csv