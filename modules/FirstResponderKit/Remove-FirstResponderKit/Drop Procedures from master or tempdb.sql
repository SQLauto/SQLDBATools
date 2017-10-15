USE master
GO
IF OBJECT_ID('dbo.sp_WhoIsActive') IS NOT NULL
	DROP PROCEDURE dbo.sp_WhoIsActive
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_WhoIsActive') IS NOT NULL
	DROP PROCEDURE dbo.sp_WhoIsActive
GO

--	
USE master
GO
IF OBJECT_ID('dbo.sp_Blitz') IS NOT NULL
	DROP PROCEDURE dbo.sp_Blitz
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_Blitz') IS NOT NULL
	DROP PROCEDURE dbo.sp_Blitz
GO

--
USE master
GO
IF OBJECT_ID('dbo.sp_BlitzCache') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzCache
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_BlitzCache') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzCache
GO

--
IF OBJECT_ID('dbo.sp_BlitzFirst') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzFirst
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_BlitzFirst') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzFirst
GO

--	
USE master
GO
IF OBJECT_ID('dbo.sp_BlitzIndex') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzIndex
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_BlitzIndex') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzIndex
GO

--
USE master
GO
IF OBJECT_ID('dbo.sp_BlitzWho') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzWho
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_BlitzWho') IS NOT NULL
	DROP PROCEDURE dbo.sp_BlitzWho
GO

--
USE master
GO
IF OBJECT_ID('dbo.sp_foreachdb') IS NOT NULL
	DROP PROCEDURE dbo.sp_foreachdb
GO
USE tempdb
GO
IF OBJECT_ID('dbo.sp_foreachdb') IS NOT NULL
	DROP PROCEDURE dbo.sp_foreachdb
GO