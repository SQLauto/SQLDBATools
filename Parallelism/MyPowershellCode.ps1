 Param(
       [String]$sqlServer
    )

$scriptpath = $MyInvocation.MyCommand.Path
$Global:jobdir = Split-Path $scriptpath
Set-Location -Path $jobdir

#Write-Output "scriptpath = $scriptpath" | out-file 'c:\temp\MyPowershellCode_logs.txt' -Append;
#Write-Output "Working directory is $jobdir" | out-file 'c:\temp\MyPowershellCode_logs.txt' -Append;
Write-Output "Running sql script MySQLScript.sql on server $sqlServer" | Out-File "c:\temp\MyPowershellCode_Logs.txt" -Append;

$rs = Invoke-Sqlcmd -ServerInstance $sqlServer -Database 'master' ` -InputFile 'C:\temp\MySQLScript.sql'
<#
                    -Query "
SELECT	@@SERVERNAME as InstanceName, 
		SERVERPROPERTY('ProductVersion') AS ProductVersion,
		SERVERPROPERTY('Edition') AS Edition, 
		SERVERPROPERTY('IsHadrEnabled') AS IsHadrEnabled, 
		SERVERPROPERTY('IsClustered') AS IsClustered;
";
#>

Write-Output $rs | Out-File "C:\temp\Logs\$sqlServer.txt";
#Write-Output $rs;
#Write-Output $rs | Out-File "c:\temp\MyPowershellCode_Results.txt" -Append;
        
    
