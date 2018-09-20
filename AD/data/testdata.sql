USE [testdb]
GO
/****** Object:  StoredProcedure [dbo].[Get_Test_Data]    Script Date: 9/20/2018 5:14:29 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[Get_Test_Data]
GO
/****** Object:  Table [dbo].[testdata]    Script Date: 9/20/2018 5:14:29 PM ******/
DROP TABLE IF EXISTS [dbo].[testdata]
GO
/****** Object:  User [WIN\BACKEND$]    Script Date: 9/20/2018 5:14:29 PM ******/
DROP USER IF EXISTS [WIN\BACKEND$]
GO
USE [master]
GO
/****** Object:  Login [##MS_PolicyEventProcessingLogin##]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'##MS_PolicyEventProcessingLogin##')
DROP LOGIN [##MS_PolicyEventProcessingLogin##]
GO
/****** Object:  Login [##MS_PolicyTsqlExecutionLogin##]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'##MS_PolicyTsqlExecutionLogin##')
DROP LOGIN [##MS_PolicyTsqlExecutionLogin##]
GO
/****** Object:  Login [NT AUTHORITY\SYSTEM]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT AUTHORITY\SYSTEM')
DROP LOGIN [NT AUTHORITY\SYSTEM]
GO
/****** Object:  Login [NT Service\MSSQL$IISTEST]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT Service\MSSQL$IISTEST')
DROP LOGIN [NT Service\MSSQL$IISTEST]
GO
/****** Object:  Login [NT SERVICE\SQLAgent$IISTEST]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\SQLAgent$IISTEST')
DROP LOGIN [NT SERVICE\SQLAgent$IISTEST]
GO
/****** Object:  Login [NT SERVICE\SQLTELEMETRY$IISTEST]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\SQLTELEMETRY$IISTEST')
DROP LOGIN [NT SERVICE\SQLTELEMETRY$IISTEST]
GO
/****** Object:  Login [NT SERVICE\SQLWriter]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\SQLWriter')
DROP LOGIN [NT SERVICE\SQLWriter]
GO
/****** Object:  Login [NT SERVICE\Winmgmt]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\Winmgmt')
DROP LOGIN [NT SERVICE\Winmgmt]
GO
/****** Object:  Login [WIN\Andy]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'WIN\Andy')
DROP LOGIN [WIN\Andy]
GO
/****** Object:  Login [WIN\BACKEND$]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'WIN\BACKEND$')
DROP LOGIN [WIN\BACKEND$]
GO
/****** Object:  Login [WIN\winadmin]    Script Date: 9/20/2018 5:14:29 PM ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'WIN\winadmin')
DROP LOGIN [WIN\winadmin]
GO
/****** Object:  Database [testdb]    Script Date: 9/20/2018 5:14:29 PM ******/
DROP DATABASE IF EXISTS [testdb]
GO
/****** Object:  Database [testdb]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'testdb')
BEGIN
CREATE DATABASE [testdb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'testdb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.IISTEST\MSSQL\DATA\testdb.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'testdb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.IISTEST\MSSQL\DATA\testdb_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
END
GO
ALTER DATABASE [testdb] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [testdb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [testdb] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [testdb] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [testdb] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [testdb] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [testdb] SET ARITHABORT OFF 
GO
ALTER DATABASE [testdb] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [testdb] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [testdb] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [testdb] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [testdb] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [testdb] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [testdb] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [testdb] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [testdb] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [testdb] SET  DISABLE_BROKER 
GO
ALTER DATABASE [testdb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [testdb] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [testdb] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [testdb] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [testdb] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [testdb] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [testdb] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [testdb] SET RECOVERY FULL 
GO
ALTER DATABASE [testdb] SET  MULTI_USER 
GO
ALTER DATABASE [testdb] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [testdb] SET DB_CHAINING OFF 
GO
ALTER DATABASE [testdb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [testdb] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [testdb] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'testdb', N'ON'
GO
ALTER DATABASE [testdb] SET QUERY_STORE = OFF
GO
USE [testdb]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
/****** Object:  Login [WIN\winadmin]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'WIN\winadmin')
CREATE LOGIN [WIN\winadmin] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [WIN\BACKEND$]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'WIN\BACKEND$')
CREATE LOGIN [WIN\BACKEND$] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [WIN\Andy]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'WIN\Andy')
CREATE LOGIN [WIN\Andy] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [NT SERVICE\Winmgmt]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\Winmgmt')
CREATE LOGIN [NT SERVICE\Winmgmt] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [NT SERVICE\SQLWriter]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\SQLWriter')
CREATE LOGIN [NT SERVICE\SQLWriter] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [NT SERVICE\SQLTELEMETRY$IISTEST]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\SQLTELEMETRY$IISTEST')
CREATE LOGIN [NT SERVICE\SQLTELEMETRY$IISTEST] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [NT SERVICE\SQLAgent$IISTEST]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT SERVICE\SQLAgent$IISTEST')
CREATE LOGIN [NT SERVICE\SQLAgent$IISTEST] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [NT Service\MSSQL$IISTEST]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT Service\MSSQL$IISTEST')
CREATE LOGIN [NT Service\MSSQL$IISTEST] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/****** Object:  Login [NT AUTHORITY\SYSTEM]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NT AUTHORITY\SYSTEM')
CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [##MS_PolicyTsqlExecutionLogin##]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'##MS_PolicyTsqlExecutionLogin##')
CREATE LOGIN [##MS_PolicyTsqlExecutionLogin##] WITH PASSWORD=N'uvduT8EfBxP5JMllYHhMl093i9KcS5fEsHuWKqIGoog=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
ALTER LOGIN [##MS_PolicyTsqlExecutionLogin##] DISABLE
GO
/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [##MS_PolicyEventProcessingLogin##]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'##MS_PolicyEventProcessingLogin##')
CREATE LOGIN [##MS_PolicyEventProcessingLogin##] WITH PASSWORD=N'IL6DcSd82v2hUoIJtfBXPx/cvhQT+G3hEAJHIhAJOVk=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
ALTER LOGIN [##MS_PolicyEventProcessingLogin##] DISABLE
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [WIN\winadmin]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [WIN\BACKEND$]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [WIN\Andy]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT SERVICE\Winmgmt]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT SERVICE\SQLWriter]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT SERVICE\SQLAgent$IISTEST]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT Service\MSSQL$IISTEST]
GO
USE [testdb]
GO
/****** Object:  User [WIN\BACKEND$]    Script Date: 9/20/2018 5:14:29 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'WIN\BACKEND$')
CREATE USER [WIN\BACKEND$] FOR LOGIN [WIN\BACKEND$] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [WIN\BACKEND$]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [WIN\BACKEND$]
GO
/****** Object:  Table [dbo].[testdata]    Script Date: 9/20/2018 5:14:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[testdata]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[testdata](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](256) NULL,
	[UPN] [nvarchar](256) NULL,
	[Value] [int] NULL,
 CONSTRAINT [PK_testdata] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
INSERT [dbo].[testdata] ([ID], [Name], [UPN], [Value]) VALUES (1, N'User1', N'user1@win.local', 123)
GO
INSERT [dbo].[testdata] ([ID], [Name], [UPN], [Value]) VALUES (2, N'User1', N'user1@win.local', 234)
GO
INSERT [dbo].[testdata] ([ID], [Name], [UPN], [Value]) VALUES (3, N'User2', N'user2@win.local', 345)
GO
INSERT [dbo].[testdata] ([ID], [Name], [UPN], [Value]) VALUES (4, N'User2', N'user2@win.local', 456)
GO
INSERT [dbo].[testdata] ([ID], [Name], [UPN], [Value]) VALUES (5, N'All', N'all', 567)
GO
/****** Object:  StoredProcedure [dbo].[Get_Test_Data]    Script Date: 9/20/2018 5:14:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Get_Test_Data]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Get_Test_Data] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Get_Test_Data] 
	-- Add the parameters for the stored procedure here
	@UPN nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [ID]
      ,[Name]
      ,[UPN]
      ,[Value]
	FROM [testdb].[dbo].[testdata]
	WHERE 
		LOWER([testdb].[dbo].[testdata].[UPN]) IN (LOWER(@UPN), 'all')
END
GO
USE [master]
GO
ALTER DATABASE [testdb] SET  READ_WRITE 
GO
