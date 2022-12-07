# windows firewall
New-NetFirewallRule -DisplayName "SQL Server (tcp/1433)" -Name "SQLServer-tcp1433" -Profile Any -LocalPort 1433 -Protocol TCP
New-NetFirewallRule -DisplayName "SQL Server (tcp/5022)" -Name "SQLServer-tcp5022" -Profile Any -LocalPort 5022 -Protocol TCP

# get status of windows defender
Get-MpComputerStatus | Select-Object -Property Antivirusenabled,AMServiceEnabled,AntispywareEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,NISEnabled,OnAccessProtectionEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated
 
Get-MpComputerStatus | Select-Object -Property Antivirusenabled,AMServiceEnabled,AntispywareEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,NISEnabled,OnAccessProtectionEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated,AntispywareSignatureLastUpdated,NISSignatureLastUpdated

# setup SQL Server for logging additional info for TLS/SSL sessions about used encryption algo and ciphers
# SQL Server create extended event recording
/*CREATE EVENT SESSION [tls] ON SERVER
ADD EVENT sqlsni.trace(
    WHERE ([sqlserver].[like_i_sql_unicode_string]([text],N'%Handshake%'))) */
--SELECT * FROM sys.server_event_sessions ;

# sql server 2019
CREATE EVENT SESSION [TLS] ON SERVER
ADD EVENT sqlsni.sni_trace(
    WHERE ([function_name]='Ssl::Handshake' AND [sqlserver].[like_i_sql_unicode_string]([text],N'SNISecurity Handshake Handshake Succeeded.%'))),
ADD EVENT sqlsni.trace
ADD TARGET package0.histogram(SET filtering_event_name=N'sqlsni.sni_trace',slots=(2048),source=N'text',source_type=(0))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

CREATE EVENT SESSION [tls] ON SERVER 
ADD EVENT sqlsni.trace(
    WHERE ([sqlserver].[like_i_sql_unicode_string]([text],N'%Handshake%')))
ADD TARGET package0.ring_buffer(SET max_events_limit=(100000),max_memory=(10240))
WITH (MAX_MEMORY=10240 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

CREATE EVENT SESSION [tls] ON SERVER
ADD EVENT sqlsni.trace(
    WHERE (([sqlserver].[like_i_sql_unicode_string]([text],N'%Handshake%TLS1.0%'))
 OR ([sqlserver].[like_i_sql_unicode_string]([text],N'%Handshake%TLS1.1%'))
 OR ([sqlserver].[like_i_sql_unicode_string]([text],N'%Handshake%TLS1.2%'))
))
ALTER EVENT SESSION [tls] ON SERVER
ADD TARGET package0.ring_buffer(SET max_events_limit=(100000),max_memory=(10240))
 WITH (MAX_MEMORY=10240 KB,STARTUP_STATE=ON)
GO
ALTER EVENT SESSION tls ON SERVER STATE = START; 



# sql server - list all available XEvents:
SELECT p.name AS package, c.event, k.keyword, c.channel, c.description
FROM
(
SELECT event_package=o.package_guid, o.description,
event=c.OBJECT_NAME, channel=v.map_value
FROM sys.dm_xe_objects o
LEFT JOIN sys.dm_xe_object_columns c ON o.name = c.OBJECT_NAME
INNER JOIN sys.dm_xe_map_values v ON c.type_name = v.name
AND c.column_value = CAST(v.map_key AS NVARCHAR)
WHERE object_type='event' AND (c.name = 'channel' OR c.name IS NULL)
) c LEFT JOIN
(
SELECT event_package=c.object_package_guid, event=c.OBJECT_NAME,
keyword=v.map_value
FROM sys.dm_xe_object_columns c INNER JOIN sys.dm_xe_map_values v
ON c.type_name = v.name AND c.column_value = v.map_key
AND c.type_package_guid = v.object_package_guid
INNER JOIN sys.dm_xe_objects o ON o.name = c.OBJECT_NAME
AND o.package_guid=c.object_package_guid
WHERE object_type='event' AND c.name = 'keyword'
) k
ON
k.event_package = c.event_package AND (k.event = c.event OR k.event IS NULL)
INNER JOIN sys.dm_xe_packages p
ON p.guid=c.event_package
WHERE (p.capabilities IS NULL OR p.capabilities&1 = 0)
ORDER BY event, keyword, channel


# after upgrade ngen powershell assemblies, otherwise powershell is sloooow 
$env:PATH = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
    $path = $_.Location
    if ($path) { 
        $name = Split-Path $path -Leaf
        Write-Host -ForegroundColor Yellow "`r`nRunning ngen.exe on '$name'"
        ngen.exe install $path /nologo
    }
}

# same, but on win2022
# win2022
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
     $path = $_.Location
     if ($path) {
         $name = Split-Path $path -Leaf
         Write-Host -ForegroundColor Yellow "`r`nRunning ngen.exe on '$name'"
          C:\windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install $path /nologo
     }
}


# check current powershell version
echo $PSVersionTable.PSVersion
Get-Host

# search for commands with "dsc" in name:
Get-Command -Noun "dsc*"

# get available, configurable resources
Get-DscResource

# list of group objects and groups membership
gpresult /V

# update policies (on the client)
gpupdate /force

# windows port forwarding
#list ruls:
netsh interface portproxy dump

#add rule:
netsh interface portproxy add v4tov4 listenport=777 listenaddress=10.100.200.10 connectport=666 connectaddress=172.16.200.10

# check if SMB 1.0 is installed 
Get-WindowsFeature FS-SMB1

# disable SMB-1.0
Disable-WindowsOptionalFeature -Online -FeatureName smb2protocol

# check if SMB2/3 is available
Get-SmbServerConfiguration | Select EnableSMB2Protocol
# disable SMB 2.0
Set-SmbServerConfiguration -EnableSMB2Protocol $false

# add path to PATH on windows
$Env:path += ";C:\Program Files\7-Zip\"
$Env:path += ";C:\app\7-Zip\"
# archive files in current directory with 7zip on windows
Get-ChildItem . -Filter u_ex1907*.log  | Foreach-Object { $fname = $_.FullName; $zname = $fname + ".zip" ; 7z a $zname $_.FullName }

# windows cleanup - after upgrades to save space
Dism.exe /online /Cleanup-Image /StartComponentCleanup
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Dism.exe /online /Cleanup-Image /SPSuperseded

# force .NET to use system default (highest) encryption,  instead of defaulting to TLS/1.0
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:64
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:32
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:64
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:32

# check what process listens on given port in windows:
Get-Process -Id (Get-NetTCPConnection -LocalPort portNumber).OwningProcess

########## powershell script run from Task Scheduler ###################
Action: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
args: -file "C:\scripts\LogsCleanupScript.ps1"

# powershell - display services
 Get-Service | Where-Object {$_.Status -eq "Running"}  | select -property name,status,starttype,displayname | out-string -Width 200


# sql server - top 20 worst performing queries
SELECT TOP 20
total_worker_time/execution_count AS Avg_CPU_Time
,Execution_count
,total_elapsed_time/execution_count as AVG_Run_Time
,total_elapsed_time
,(SELECT
SUBSTRING(text,statement_start_offset/2+1,statement_end_offset
) FROM sys.dm_exec_sql_text(sql_handle)
) AS Query_Text
FROM sys.dm_exec_query_stats
ORDER BY Avg_CPU_Time DESC

# get windows eventlogs sources for 'Application' channel
Get-EventLog -LogName Application |Select-Object Source -Unique 





