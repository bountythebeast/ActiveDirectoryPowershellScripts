<#
    Scripts created by https://github.com/bountythebeast.
    
    # All of these scripts are free to use, edit, and reupload.
    # These were created by stitching together other code, or writing my own from the ground up.
    # I do not take full credit for anything.

    Support:
        While I won't troubleshoot every error, major issues can be reported on my github. https://github.com/bountythebeast/ActiveDirectoryPowershellScripts

    Instructions:
        1. Update $percentCritical as needed. 
            > This number is % of free space left. EI 10 = 10% free or less.
        2. Update $reportPath
        3. Update $computers - 1 computer per line.
    
    Notes:
        Standard disk space report. Only shows those systems where a harddrive has < $percentCritical space free. 

#>

$ErrorActionPreference = "Continue";

# Set your warning and critical thresholds
$percentCritcal = 10;

# Path to the report
$reportPath = "$home\Desktop\"; # ------------------EDIT------------------#

# Report name
$reportName = "DiskSpaceRpt_$(get-date -format ddMMyyyy).html";

# Path and Report name together
$diskReport = $reportPath + $reportName

#Set colors for table cell backgrounds
$redColor = "#FF0000"
$orangeColor = "#FBB917"
$whiteColor = "#FFFFFF"

# Count if any computers have low disk space.  Do not send report if less than 1.
$i = 0;

# Get computer list to check disk space
$computers = Get-Content "$home\Desktop\serverlist.txt"; # -------------------EDIT------------------#
$datetime = Get-Date -Format "MM-dd-yyyy_HHmmss";

# Remove the report if it has already been run today so it does not append to the existing report
If (Test-Path $diskReport)
    {
        Remove-Item $diskReport
    }

# Create and write HTML Header of report
$titleDate = get-date -uformat "%A - %m-%d-%Y"
$header = "
		<html>
		<head>
		<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
		<title>DiskSpace Report</title>
		<STYLE TYPE='text/css'>
		<!--
		td {
			font-family: Tahoma;
			font-size: 11px;
			border-top: 1px solid #999999;
			border-right: 1px solid #999999;
			border-bottom: 1px solid #999999;
			border-left: 1px solid #999999;
			padding-top: 0px;
			padding-right: 0px;
			padding-bottom: 0px;
			padding-left: 0px;
		}
		body {
			margin-left: 5px;
			margin-top: 5px;
			margin-right: 0px;
			margin-bottom: 10px;
			table {
			border: thin solid #000000;
		}
		-->
		</style>
		</head>
		<body>
		<table width='100%'>
		<tr bgcolor='#CCCCCC'>
		<td colspan='7' height='25' align='center'>
		<font face='tahoma' color='#003399' size='4'><strong>Everest DiskSpace Report for $titledate</strong></font>
		</td>
		</tr>
		</table>
"
 Add-Content $diskReport $header

# Create and write Table header for report
 $tableHeader = "
 <table width='100%'><tbody>
	<tr bgcolor=#CCCCCC>
    <td width='10%' align='center'>Server</td>
	<td width='5%' align='center'>Drive</td>
	<td width='10%' align='center'>Total Capacity(GB)</td>
	<td width='10%' align='center'>Used Capacity(GB)</td>
	<td width='10%' align='center'>Free Space(GB)</td>
	<td width='5%' align='center'>Freespace %</td>
	</tr>
"
Add-Content $diskReport $tableHeader
 
# Start processing disk space reports against a list of servers
  foreach($computer in $computers){	
  if(Test-Connection -ComputerName $computer -Count 1 -ea 0) {
    $disks = $null
	$disks = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter "DriveType = 3"
	$computer = $computer.toupper()
		foreach($disk in $disks)
	{        
        #null variables before run
        $deviceID = $null
        $size = $null
        $freespace = $null
        $percentFree = $null
        $sizeGB = $null
        $freeSpaceGB = $null
        $usedSpaceGB = $null
        #end null 

		$deviceID = $disk.DeviceID;
		[float]$size = $disk.Size;
		[float]$freespace = $disk.FreeSpace; 
		$percentFree = [Math]::Round(($freespace / $size) * 100, 1);
		$sizeGB = [Math]::Round($size / 1073741824, 2);
		$freeSpaceGB = [Math]::Round($freespace / 1073741824, 2);
        $usedSpaceGB = $sizeGB - $freeSpaceGB;
        $color = $whiteColor;

# Set background color to Orange if just a warning
# Set background color to Orange if space is Critical
      if($percentFree -lt $percentCritcal)
        {
        $color = $redColor
               
 
 # Create table data rows 
    $dataRow = "
		<tr>
        <td width='10%'>$computer</td>
		<td width='5%' align='center'>$deviceID</td>
		<td width='10%' align='center'>$sizeGB</td>
		<td width='10%' align='center'>$usedSpaceGB</td>
		<td width='10%' align='center'>$freeSpaceGB</td>
		<td width='5%' bgcolor=`'$color`' align='center'>$percentFree</td>
		</tr>
"
Add-Content $diskReport $dataRow;
Write-Host -ForegroundColor DarkYellow "$computer $deviceID percentage free space = $percentFree";
    $i++		
		}
	}
}
$computer = $null
}

# Create table at end of report showing legend of colors for the critical and warning
 $tableDescription = "
 </table><br><table width='20%'>
	<tr bgcolor='White'>
    <td width='10%' align='center' bgcolor='#FBB917'>Warning = Less than 11% free space</td>
	<td width='10%' align='center' bgcolor='#FF0000'>Critical = Less than 10% free space</td>
	</tr>
"
 	Add-Content $diskReport $tableDescription
	Add-Content $diskReport "</body></html>"
