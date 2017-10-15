Function Get-ServerInfo
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('ServerName','MachineName')]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )

    $Result = @();

    foreach ($comp in $ComputerName)
    {
        $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $comp
        $cs = Get-WmiObject -Class win32_computersystem -ComputerName $comp
        $bt = (Get-CimInstance -ClassName win32_operatingsystem  -ComputerName $comp | select lastbootuptime);

        $props = [Ordered]@{ 'ComputerName'=$comp;
                    'OS'=$os.Caption;
                    'SPVersion'=$os.CSDVersion;
                    'LastBootTime'=$bt.LastBootUpTime;
                    #'Mfgr'=$cs.manufacturer;
                    'Model'=$cs.Model;
                    'RAM(MB)'=$cs.totalphysicalmemory/1MB -AS [int];
                    'CPU'=$cs.NumberOfLogicalProcessors;
                  }
        
        $obj = New-Object -TypeName psobject -Property $props;
        #Write-Output $obj
        $Result += $obj;
    }
    Write-Output $Result;
}

Function Get-VolumeInfo
{
    Param (
            [Alias('ServerName','MachineName')]
            [String[]]$ComputerName = $env:COMPUTERNAME
          )

    BEGIN {
    $diskInfo = @();
    }
    PROCESS {
        if ($_ -ne $null)
        {
            $ComputerName = $_;
            Write-Verbose "Parameters received from PipeLine.";
        }
        foreach ($Computer in $ComputerName)
        {
            $diskInfo +=  Get-WmiObject -Class win32_volume -ComputerName $Computer -Filter "DriveType=3" | 
            Select-Object -Property @{l='ComputerName';e={$_.PSComputerName}}, 
                                    @{l='VolumeName';e={$_.Name}}, 
                                    @{l='Capacity(GB)';e={$_.Capacity / 1GB -AS [INT]}},
                                    @{l='Used Space(GB)';e={($_.Capacity - $_.FreeSpace)/ 1GB -AS [INT]}},
                                    @{l='Used Space(%)';e={((($_.Capacity - $_.FreeSpace) / $_.Capacity) * 100) -AS [INT]}},
                                    @{l='FreeSpace(GB)';e={$_.FreeSpace / 1GB -AS [INT]}},
                                    Label
        }
    }
    END {
        Write-Output $diskInfo;
    }
}

Function Analyze-DBFiles
{
    Param (
        [Alias('ServerName','MachineName','InstanceName')]
        [String[]]$ComputerName
    )

    BEGIN {}
    PROCESS {
        $ScriptPath = $PSScriptRoot+'\Automation - Restrict File growth.sql';
        Write-Verbose "Script path is $ScriptPath";

        foreach ($sqlInstance in $ComputerName)
        {
            # Compile Procedure on tempdb
            Write-Verbose "Compiling the procedure code from script $ScriptPath";
            Invoke-Sqlcmd -ServerInstance $sqlInstance -Database 'tempdb' -InputFile $ScriptPath;

            Write-Verbose "Executing the procedure usp_AnalyzeSpaceCapacity";
            $rs = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database tempdb -Query 'exec [dbo].[usp_AnalyzeSpaceCapacity]';
        
            Write-Output $rs
        }
    }
    END {}
}

Function Get-RunningQueries
{
    Param (
            [Alias('ServerName','MachineName')]
            [String[]]$ComputerName = $env:COMPUTERNAME
          )

    BEGIN {
    $sessions = @();
    }
    PROCESS {
        if ($_ -ne $null)
        {
            $ComputerName = $_;
            Write-Verbose "Parameters received from PipeLine.";
        }
        foreach ($Computer in $ComputerName)
        {
            #cd $PSScriptRoot;
            Write-Verbose "Running $PSScriptRoot\WhatIsRunning.sql against $Computer.. Please wait..";
            $sessions = Invoke-Sqlcmd -ServerInstance $Computer -Database master -InputFile "$PSScriptRoot\WhatIsRunning.sql"
        }
    }
    END {
        Write-Output $sessions;
    }
}

Function Run-sp_WhoIsActive
{
    Param (
            [Alias('ServerName','MachineName')]
            [String[]]$ComputerName = $env:COMPUTERNAME
          )

    BEGIN {
    $sessions = @();
    }
    PROCESS {
        if ($_ -ne $null)
        {
            $ComputerName = $_;
            Write-Verbose "Parameters received from PipeLine.";
        }
        foreach ($Computer in $ComputerName)
        {
            #cd $PSScriptRoot;
            Write-Verbose "Running sp_WhoIsActive against $Computer.. Please wait..";
            $sessions = Invoke-Sqlcmd -ServerInstance $Computer -Database tempdb -Query 'EXEC dbo.sp_WhoIsActive @get_plans=1, @get_full_inner_text=1, @get_transaction_info=1, @get_task_info=2, @get_locks=1, @get_avg_time=1, @get_additional_info=1,@find_block_leaders=1'
        }
    }
    END {
        Write-Output $sessions;
    }
}