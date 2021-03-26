<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Run Script, and follow on screen instructions.
    
    Notes:
        Your credentials are NOT encrypted by this script. Please research a different option or how to do this if you would like them stored a different way. 

#>

Write-Host "Please go to console.aws.amazon.com, sign in and go to IAM. Then go to users, and find yourself. Under Security Credentials, You will now need to create an access key. This will provide an Access key ID and secret key."
Write-Host "SAVE THE SECRET KEY IN SAFE IN CLOUD!!! It will not be attainable after you close the window; and a new access key will need to be generated. "

Write-Warning "Please Note. Your access and secret are NOT encrypted by this script. This means it is in plain text. Please use a different method if you feel unsafe about this."

$accesskey = Read-Host "Enter your Access Key: "
$secretkey = Read-Host "Enter your SECRET Key: "
$region = Read-Host "Enter the region! (no entry will default to us-east-1)"
if(($region -like $null) -or ($region -like "us-east-1"))
{
    $region = "us-east-1"
}
else
{
    write-host "Warning! Not using default region: us-east-1; using $region!"
}

$environment = Read-Host "Enter your environment tag for storing more than one access key."
Write-host "Default credentials set to $environment"



Set-AWSCredential -AccessKey $accesskey -SecretKey $secretkey -StoreAs $environment

$accesskey = $null
$secretkey = $null
Set-AWSCredential -ProfileName $environment

get-awscredential -ListProfileDetail
Initialize-AWSDefaultConfiguration -ProfileName $environment -Region us-east-1

Write-Host "post script completion you will have the aws credentials on this computer listed..."


Write-Host "Script has defaulted your credentials from: $environment for all scripts unless a different profile is specified. "
Read-Host -Prompt "Press any Key to close this window."