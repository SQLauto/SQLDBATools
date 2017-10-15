Function Apply-FirstResponderKit {
<#
.SYNOPSIS
Creates procedures sp_whoIsActive, sp_BlitzFirst, sp_Blitz, sp_BlitzCache, sp_BlitzIndex against tempdb of SQL Server for health Checks and Performance Tuning.
.DESCRIPTION
This command helps to create sp_Blitz procedures that come as part of FirstResponder kit on any SQL Server. Latest version of FirstResponder Kit can be downloaded from url:-
https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit
.PARAMETER ServerName
Name of the server where sp_Blitz procedures need to be created.
For Example:
Apply-FirstResponderKit -ServerName ServerName01
.EXAMPLE
 Apply-FirstResponderKit -ServerName DBSW8197
 This example will create procedures tempdb..sp_Blitz, tempdb..sp_BlitzCache, tempdb..sp_whoIsActive etc on SQL Server instance DBSW8197. Script for these procedures will be searched under 'Apply-FirstResponderKit' folder.
.EXAMPLE
 Apply-FirstResponderKit -ServerName DBSWS8197 -scriptPath 'C:\Scripts'
 This example will execute all scripts from path 'C:\Scripts' on tempdb database of SQL Server instance DBSW8197.
.EXAMPLE
 Apply-FirstResponderKit -ServerName (Get-Content 'C:\SQLServers.txt')
 This example will create procedures tempdb..sp_Blitz, tempdb..sp_BlitzCache, tempdb..sp_whoIsActive etc on SQL Server instance names taken from file 'C:\SQLServers.txt'. Script for these procedures will be searched under 'Apply-FirstResponderKit' folder.
.EXAMPLE
 Apply-FirstResponderKit -ServerName dbsed3304,dbsw8197
 This example will create procedures tempdb..sp_Blitz, tempdb..sp_BlitzCache, tempdb..sp_whoIsActive etc on SQL Server instance dbsed3304 & dbsw8197. Script for these procedures will be searched under 'Apply-FirstResponderKit' folder.
.LINK
https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit
.LINK
https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/releases
.LINK
http://sqlblog.com/blogs/adam_machanic/archive/2012/03/22/released-who-is-active-v11-11.aspx
.LINK
http://ajaydwivedi.com/2017/05/log-all-activities-using-sp_whoisactive-2/
.LINK
http://ajaydwivedi.com/2016/12/log-all-activities-using-sp_whoisactive/
.LINK
http://ajaydwivedi.com/2016/11/why-my-query-is-slow/
#>
    Param (
               [Alias('ComputerName')][String[]]$ServerName = $env:COMPUTERNAME,
               [String]$scriptPath = $PSScriptRoot+'\Apply-FirstResponderKit'
          )

    BEGIN {
        $blitzScriptFiles = Get-ChildItem -Path $scriptPath | Where-Object -Property Extension -EQ '.sql';
    }
    PROCESS {
        foreach ($server in $ServerName)
        {
            foreach ($scriptFile in $blitzScriptFiles)
            {
                try 
                {
                    Write-Host "Executing script '$($scriptFile.Name)' on [$server] server.";
                    Invoke-Sqlcmd -ServerInstance $server -Database tempdb -InputFile $scriptFile.FullName | Out-File -FilePath "$($scriptFile.Directory)\$($scriptFile.BaseName)__OUTPUT.txt"
                }
                catch
                {
                    Write-Host "        Error occurred" -BackgroundColor Yellow -ForegroundColor Red 
                }
            }
        }
    }
    END {}
}
Function Remove-FirstResponderKit 
{
    Param (
               [String]$ServerName = $env:COMPUTERNAME,
               [String]$scriptPath = $PSScriptRoot+'\Remove-FirstResponderKit'
          )

    $blitzScriptFiles = Get-ChildItem -Path $scriptPath | Where-Object -Property Extension -EQ '.sql';
    
    foreach ($scriptFile in $blitzScriptFiles)
    {
        try 
        {
            Write-Host "Dropping sp_Blitz scripts from [$ServerName] server.";            
            Invoke-Sqlcmd -ServerInstance $ServerName -InputFile $scriptFile.FullName | Out-File -FilePath "$($scriptFile.Directory)\$($scriptFile.BaseName)__OUTPUT.txt"
        }
        catch
        {
            Write-Host "        Error occurred" -BackgroundColor Yellow -ForegroundColor Red 
        }
    }
}