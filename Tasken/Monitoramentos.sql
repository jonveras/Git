USE TaskenMaintDB
GO

--------------------------------------------------------------------------------------------------------------------------------
--	Criação da tabela de whoisactive
--------------------------------------------------------------------------------------------------------------------------------

if OBJECT_ID('Resultado_WhoisActive') is not null
	drop table Resultado_WhoisActive

CREATE TABLE Resultado_WhoisActive  (
      Dt_Log DATETIME ,
      [dd hh:mm:ss.mss] VARCHAR(8000) NULL ,
      [database_name] VARCHAR(128) NULL ,
      [session_id] SMALLINT NOT NULL ,
      blocking_session_id SMALLINT NULL ,
      [sql_text] XML NULL ,
      [login_name] VARCHAR(128) NOT NULL ,
      [wait_info] VARCHAR(4000) NULL ,
      [status] VARCHAR(30) NOT NULL ,
      [percent_complete] VARCHAR(30) NULL ,
      [host_name] VARCHAR(128) NULL ,
      [sql_command] XML NULL ,
      [CPU] VARCHAR(100) ,
      [reads] VARCHAR(100) ,
      [writes] VARCHAR(100),
	  [Program_Name] VARCHAR(100)
    );

--------------------------------------------------------------------------------------------------------------------------------
--	Criação da tabela de contadores
--------------------------------------------------------------------------------------------------------------------------------

if OBJECT_ID('Contador') is not null
	drop table Contador

if OBJECT_ID('Registro_Contador') is not null
	drop table Registro_Contador

CREATE TABLE Contador(Id_Contador INT identity, Nm_Contador VARCHAR(50))

INSERT INTO Contador (Nm_Contador)
SELECT 'BatchRequests'
INSERT INTO Contador (Nm_Contador)
SELECT 'User_Connection'
INSERT INTO Contador (Nm_Contador)
SELECT 'CPU'
INSERT INTO Contador (Nm_Contador)
SELECT 'Page Life Expectancy'

SELECT * FROM Contador

CREATE TABLE [dbo].[Registro_Contador](
	[Id_Registro_Contador] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[Id_Contador] [int] NULL,
	[Valor] [int] NULL
) ON [PRIMARY]

--------------------------------------------------------------------------------------------------------------------------------
--	Criação da procedure para dar carga na tabela de contadores
--------------------------------------------------------------------------------------------------------------------------------
if OBJECT_ID('stpCarga_ContadoresSQL') is not null
	drop procedure stpCarga_ContadoresSQL

GO
CREATE PROCEDURE stpCarga_ContadoresSQL
AS
BEGIN
	DECLARE @BatchRequests INT,@User_Connection INT, @CPU INT, @PLE int

	DECLARE @RequestsPerSecondSample1	BIGINT
	DECLARE @RequestsPerSecondSample2	BIGINT

	SELECT @RequestsPerSecondSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'
	WAITFOR DELAY '00:00:05'
	SELECT @RequestsPerSecondSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'
	SELECT @BatchRequests = (@RequestsPerSecondSample2 - @RequestsPerSecondSample1)/5

	select @User_Connection = cntr_Value
	from sys.dm_os_performance_counters
	where counter_name = 'User Connections'
								
	SELECT  TOP(1) @CPU  = (SQLProcessUtilization + (100 - SystemIdle - SQLProcessUtilization ) )
	FROM ( 
		  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
				AS [SystemIdle], 
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
				'int') 
				AS [SQLProcessUtilization], [timestamp] 
		  FROM ( 
				SELECT [timestamp], CONVERT(xml, record) AS [record] 
				FROM sys.dm_os_ring_buffers 
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
				AND record LIKE '%<SystemHealth>%') AS x 
		  ) AS y 
						  						  
	SELECT @PLE = cntr_value 
	FROM sys.dm_os_performance_counters
	WHERE 	counter_name = 'Page life expectancy'
		and object_name like '%Buffer Manager%'

	insert INTO Registro_Contador(Dt_Log,Id_Contador,Valor)
	Select GETDATE(), 1,@BatchRequests
	insert INTO Registro_Contador(Dt_Log,Id_Contador,Valor)
	Select GETDATE(), 2,@User_Connection

	insert INTO Registro_Contador(Dt_Log,Id_Contador,Valor)
	Select GETDATE(), 3,@CPU
	insert INTO Registro_Contador(Dt_Log,Id_Contador,Valor)
	Select GETDATE(), 4,@PLE
END  

--------------------------------------------------------------------------------------------------------------------------------
--	Criação do job da whoisactive
--------------------------------------------------------------------------------------------------------------------------------

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'[TaskenMaintDB] - Carga WhoisActive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'src', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'[TaskenMaintDB] - Carga WhoisActive', @server_name = N'SRV01'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'[TaskenMaintDB] - Carga WhoisActive', @step_name=N'Carga Whoisactive', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=3, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_WhoIsActive @get_outer_command = 1,
            @output_column_list = ''[collection_time][d%][session_id][blocking_session_id][sql_text][login_name][wait_info][status][percent_complete]
      [host_name][database_name][sql_command][CPU][reads][writes][program_name]'',
    @destination_table = ''Resultado_WhoisActive''', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'[TaskenMaintDB] - Carga WhoisActive', @step_name=N'mantem somente 7 dias', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM Resultado_WhoisActive WHERE DT_LOG < GETDATE()-7', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'[TaskenMaintDB] - Carga WhoisActive', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'src', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'[TaskenMaintDB] - Carga WhoisActive', @name=N'1 em 1 minuto', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20250704, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO


--------------------------------------------------------------------------------------------------------------------------------
--	Criação do job de contadores
--------------------------------------------------------------------------------------------------------------------------------

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'[TaskenMaintDB] - CargaContadores', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'src', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'[TaskenMaintDB] - CargaContadores', @server_name = N'SRV01'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'[TaskenMaintDB] - CargaContadores', @step_name=N'Carga Contadores', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=3, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpCarga_ContadoresSQL', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'[TaskenMaintDB] - CargaContadores', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'src', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'[TaskenMaintDB] - CargaContadores', @name=N'1 em 1 minuto', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20250704, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO