function Uninstall-SqlInstance {
<#
    .SYNOPSIS
    This function uninstalls SQL Server Instance from a server.
    .DESCRIPTION
    This function accept SqlInstance name, and removes all the features that were originally installed with that instance. 
    This function checks for Sql Instance existence and then scan for its features, and finally remove all features.
    Also, cleans up the residual folders automatically once uninstall is completed.
    .PARAMETER SqlInstance
    Sql Server instance that has to be uninstalled. Could be local or remote.
    .EXAMPLE 
    Uninstall-SqlInstance -SqlInstance 'testvm'
    This command removes SqlInstance 'testvm' with user confirmation required.
    .EXAMPLE 
    Uninstall-SqlInstance -SqlInstance 'testvm' -Confirm:$false
    This command removes SqlInstance 'testvm' suppressing user confirmation.
    .LINK
    https://github.com/imajaydwivedi/SQLDBATools
#>
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$SqlInstance
    )
    
    $ComputerName = $SqlInstance.Split('\')[0];
    $version = 0;
    $SetupPath = $null;
    $ConfigPath = $null;
    
    if($SqlInstance.Contains('\')){
        $InstanceName = $SqlInstance.Split('\')[1]; 
        $SvcName = "MSSQL`$$InstanceName";
    }else{
        $InstanceName = 'MSSQLSERVER';
        $SvcName = "$InstanceName"
    }

    $callstack = Get-PSCallStack;
    if($callstack[1].FunctionName -eq '<ScriptBlock>') {
        $snowed = Read-Host "Have you got service now ticket? Y/N";
        $backed = Read-Host "Have you backed up databases? Y/N";

        if($snowed -ne 'Y' -or $backed -ne 'Y') {
            Write-Output "Kindly make sure you have a ServiceNow ticket for uninstall.";
            Write-Output "Kindly make sure you have taken a full backup of the databases before uninstalling."
            return;
        }
    }

    $svs = $null;
    $Features = $null;
    Write-Verbose "Finding SQL Service for SQL Instance [$SqlInstance]"
    $svs = Get-Service $SvcName -ComputerName $ComputerName -ErrorAction SilentlyContinue;
    if(-not [string]::IsNullOrEmpty($svs)) {
        Write-Verbose "Finding SQL Version";
        $srv = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlInstance)
        $version = ($srv.VersionMajor)*10;

        # Default Directories
        Write-Verbose "Finding data/log/instance/tempdb directories..";
        $INSTALLSHAREDDIR = $srv.InstallSharedDirectory;
        $INSTALLSQLDATADIR = $srv.InstallDataDirectory;
        $INSTALLSHAREDWOWDIR = $INSTALLSHAREDDIR.Replace('Program Files','Program Files (x86)');
        $SQLBACKUPDIR = $srv.BackupDirectory;
        $SQLUSERDBDIR = $srv.DefaultFile;
        $SQLUSERDBLOGDIR = $srv.DefaultLog;
        $SQLTEMPDBDIR = $srv.Databases['tempdb'].PrimaryFilePath;
        Write-Verbose "`$SQLTEMPDBDIR = '$SQLTEMPDBDIR'"
        $SQLTEMPDBLOGFILE = $srv.Databases['tempdb'].LogFiles.FileName;
        Write-Verbose "`$SQLTEMPDBLOGFILE = '$SQLTEMPDBLOGFILE'";

        Write-Verbose "Find ConfigFile and SummaryFile";        
        $LogPath = "\\$ComputerName\"+"C:\Program Files\Microsoft SQL Server\$version\Setup Bootstrap\Log\".Replace(':','$');        
        $ConfigFiles = Get-ChildItem "$LogPath*Configurationfile.ini" -Recurse | Sort-Object -Property CreationTime -Descending;
        
        foreach($file in $ConfigFiles) {
            $SummaryFile = "\\$ComputerName\c$\Program Files\Microsoft SQL Server\$version\Setup Bootstrap\Log\$($file.Directory.Name)\Summary_$($ComputerName)_$($file.Directory.Name).txt";
            $ConfigFile = ($file.FullName.Replace("\\$ComputerName\",'')).Replace('$',':');
            $SummaryFile_Content = Get-Content $SummaryFile 
            
            if( $SummaryFile_Content -match "Requested action:\s+Install" -and
                $SummaryFile_Content -match "Configuration file:\s+$([regex]::escape($ConfigFile))" -and
                $SummaryFile_Content -match "INSTANCENAME:\s+MSSQLSERVER" -and
                $SummaryFile_Content -match "FEATURES:\s+(?'Features'\w+)"
              )
            {
                Write-Verbose "Correct Configurationfile.ini is found";
                if($SummaryFile_Content | Where-Object {$_.ToString().Trim() -match "^FEATURES:\s+(?'Features'(\w+,?\s?)+)"}) {
                    $Features = $Matches['Features'];
                }

                break;
            }
        }

        $ScriptBlock = {
            $VerbosePreference = $Using:VerbosePreference;
            $ConfirmPreference = $Using:ConfirmPreference;
            $WhatIfPreference = $Using:WhatIfPreference;
            $DebugPreference = $Using:DebugPreference;
            $Version = $Using:version;
            $Features = $Using:Features;
            $InstanceName = $Using:InstanceName;
            $ComputerName = $env:COMPUTERNAME;
            $SqlInstance = if($InstanceName -eq 'MSSQLSERVER'){$ComputerName}else{$ComputerName + '\' + $InstanceName}
            $SQLTEMPDBLOGFILE = $Using:SQLTEMPDBLOGFILE;
            $SQLTEMPDBLOGDIR = (Get-Item $SQLTEMPDBLOGFILE -Force).DirectoryName;
            
            $SetupFile = Get-ChildItem "C:\Program Files\Microsoft SQL Server\$Version\Setup Bootstrap\*sql*\setup.exe" -Recurse;
            $SetupPath = $SetupFile.DirectoryName;

            Write-Verbose "Starting UnInstall for SqlInstance [$SqlInstance]";
            Set-Location $SetupPath;
            $rs = .\Setup.exe /Action=Uninstall /QUIET=true /FEATURES=$Features /INSTANCENAME=$InstanceName
            Write-Verbose ".\Setup.exe /Action=Uninstall /QUIET=true /FEATURES=$Features /INSTANCENAME=$InstanceName";

            Write-Output $rs;
            
            # Clean Up Left Over Folders
            Write-Verbose "Clearing data/log/instance/tempdb directories..";
            if(Test-Path $Using:SQLTEMPDBDIR){Remove-Item $Using:SQLTEMPDBDIR -Recurse -Force;}
            if(Test-Path $SQLTEMPDBLOGDIR) {Remove-Item $SQLTEMPDBLOGDIR -Recurse -Force;}
            if(Test-Path $Using:SQLUSERDBDIR){Remove-Item $Using:SQLUSERDBDIR -Recurse -Force;}
            if(Test-Path $Using:SQLUSERDBLOGDIR){Remove-Item $Using:SQLUSERDBLOGDIR -Recurse -Force;}
            if(Test-Path $Using:INSTALLSQLDATADIR){Remove-Item $Using:INSTALLSQLDATADIR -Recurse -Force;}
            
        }
        if($PSCmdlet.ShouldProcess("$SqlInstance")){
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock;
            
            Write-Output "Uninstall of [$SqlInstance] completed.";
        }

    } else {
        Write-Output "Sql Instance '$SqlInstance' does not exists.";
    }
}
