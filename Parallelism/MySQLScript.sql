SET NOCOUNT ON;
SELECT	@@SERVERNAME as InstanceName, 
		SERVERPROPERTY('ProductVersion') AS ProductVersion,
		SERVERPROPERTY('Edition') AS Edition, 
		SERVERPROPERTY('IsHadrEnabled') AS IsHadrEnabled, 
		SERVERPROPERTY('IsClustered') AS IsClustered
		