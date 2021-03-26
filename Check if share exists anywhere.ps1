<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $ServerList as needed. 1 server per line. Can restrict to known fileshare servers, or all.
        2. Run.
    
    Notes:
        This script was originally created to find User allocated Personal shares when they left the company.

        Script stops upon finding the first instance of a share that matches.

#>


Function ADGroup {

###################Load Assembly for creating form & button######

[void][System.Reflection.Assembly]::LoadWithPartialName( “System.Windows.Forms”)
[void][System.Reflection.Assembly]::LoadWithPartialName( “Microsoft.VisualBasic”)

#####Define the form size & placement

$form = New-Object “System.Windows.Forms.Form”;
$font = New-Object System.Drawing.Font("Arial Rounded MT Bold",8)
$form.font = $font;
$form.Width = 400;
$form.Height = 150;
$form.Text = "Check Share";
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

##############Define text label1
$textLabel1 = New-Object “System.Windows.Forms.Label”;
$font = New-Object System.Drawing.Font("Arial Rounded MT Bold",8)
$textLabel1.font = $font;
$textLabel1.Left = 15;
$textLabel1.Top = 10;
$textLabel1.Width = 100;
$textLabel1.Height = 10;
$textLabel1.Text = "Name of Share";

############Define textbox1 for input
$textBox1 = New-Object “System.Windows.Forms.TextBox”;
$textBox1.Left = 150;
$textBox1.Top = 10;
$textBox1.width = 200;
$textBox1.Text = "";

#############define OK button
$button = New-Object “System.Windows.Forms.Button”;
$button.Left = 20;
$button.Top = 50;
$button.Width = 100;
$button.Text = “Ok”;

############# This is when you have to close the form after getting values
$eventHandler = [System.EventHandler]{
$textBox1.Text;
$form.Close();};

$button.Add_Click($eventHandler) ;

#############Add controls to all the above objects defined
$form.Controls.Add($button);
$form.Controls.Add($textLabel1);
$form.Controls.Add($textBox1);
$ret = $form.ShowDialog();

#################return values
return $textBox1.Text
}

$share = ADGroup

Write-Host $share
$ServerList = gc "$home\Desktop\FileServerList.txt"
$exitprogram = $false
foreach ($ServerName in $ServerList)
{
    Write-Host "Trying: $ServerName"
    if(Test-Path "\\$ServerName\$share")
    {
        $existson = "$existson $ServerName"
        $sharename = "$sharename $share"
        Write-Host "Success"
        Get-WmiObject -Class Win32_Share -ComputerName $ServerName | Where {$_.name -like "*$share*"}
        $exitprogram = $true
        Write-Host "\\$ServerName\$share"
    }
    else
    {
        Write-Host "Not Found"
    }
    if ($exitprogram -eq $true)
    {
        exit
    }
}
if ($exitprogram -eq $false)
{
    Write-Host "Share not found"
}
