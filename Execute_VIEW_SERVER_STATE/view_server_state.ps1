$servers = Import-Csv "$PSScriptRoot\ServerList.csv";

# Get server names as array list
$instances = @($servers | select -ExpandProperty serverName);

# create Errors folder for storing errors
if (Test-Path $PSScriptRoot\Errors)
{
    Get-ChildItem -Path "$PSScriptRoot\Errors" | Remove-Item;
}else {
    New-Item "$PSScriptRoot\Errors" -type directory;
}

Remove-Item "$PSScriptRoot\Successfull_Server_List.txt" -ErrorAction Ignore;
Remove-Item "$PSScriptRoot\Failed_Server_List.txt"  -ErrorAction Ignore;

$errorServers = @();
$successServers = @();


foreach($instance in $instances)
{
    $error.Clear();
    try {
       $rs = Invoke-Sqlcmd -ServerInstance $instance -Query 'GRANT VIEW SERVER STATE TO [MS\DSM_Admin]';

       Write-Host "Executed successfully on $instance";
       $successServers += $instance;
    }
    catch {
        $errorServers += $instance;
        Write-Host "Error occurred for server: $instance" ;
        $error | Out-File "$PSScriptRoot\Errors\$instance.txt";
    }

    Write-Output "Script executed successfully for below servers:-
$successServers
" | Out-File "$PSScriptRoot\Successfull_Server_List.txt";
   
    Write-Output "Script failed for below servers:-
$errorServers
" | Out-File "$PSScriptRoot\Failed_Server_List.txt";
}
