cls

$instancesquery ="Select query to take instances from inventory here."

#$instances = Get-AdoDataTableFromSQL $MonnConnString $instancesquery
$instances = Invoke-Sqlcmd -Query $instancesquery -ServerInstance 'InventoryInstance' -Database 'InventoryDB' #-ConnectionTimeout 0 -QueryTimeout 0

Write-Host "List of servers found is as below: `
    $($instances.name -join ', ')
    ";

$servers = $instances # TypeName: System.Data.DataRow
#$instances 
$servers = @($instances | select -ExpandProperty name);

#$servers
cd C:\temp\Parallelism;
Remove-Item "c:\temp\MyPowershellCode_Logs.txt" -ErrorAction Ignore;

$stime = Get-Date

.\Run-CommandMultiThreaded.ps1 `
    -MaxThreads 3 `
    -Command MyPowershellCode.ps1 `
    -ObjectList ($servers) `
    -InputParam sqlServer -Verbose

$etime = Get-Date

$timeDiff = New-TimeSpan -Start $stime -End $etime ;
write-host $timeDiff