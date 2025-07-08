--CRIACAO DOS LOGS
--CRIACAO DA PROCEDURE DE CONTADORES E TABELAS
USE TaskenMaintDB

--------------------------------------------------------------------------------------------------------------------------------
--	Criacao das tabelas para armazenar as informacoes
--------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('Contador') IS NOT NULL
	DROP TABLE Contador

IF OBJECT_ID('Registro_Contador') IS NOT NULL
	DROP TABLE Registro_Contador

CREATE TABLE Contador(Id_Contador INT identity, Nm_Contador VARCHAR(50))

INSERT INTO Contador (Nm_Contador)
SELECT 'BatchRequests'
INSERT INTO Contador (Nm_Contador)
SELECT 'User_Connection'
INSERT INTO Contador (Nm_Contador)
SELECT 'CPU'
INSERT INTO Contador (Nm_Contador)
SELECT 'Page Life Expectancy'

CREATE TABLE [dbo].[Registro_Contador](
	[Id_Registro_Contador] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[Id_Contador] [int] NULL,
	[Valor] [int] NULL
) ON [PRIMARY]

--------------------------------------------------------------------------------------------------------------------------------
--	Criacao da procedure para dar carga na tabela
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

--CRIAR JOB DE LOG DO WHOISACTIVE
USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'[TaskenMaintDB] - Carga WhoisActive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'src', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Carga Whoisactive', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_WhoIsActive @get_outer_command = 1,
            @output_column_list = ''[collection_time][d%][session_id][blocking_session_id][sql_text][login_name][wait_info][status][percent_complete]
      [host_name][database_name][sql_command][CPU][reads][writes][program_name]'',
    @destination_table = ''Resultado_WhoisActive''', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mantem somente 7 dias', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM Resultado_WhoisActive WHERE DT_LOG < GETDATE()-7', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1 em 1 minuto', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20250704, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

--CRIAR JOB DOS CONTADORES
USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'[TaskenMaintDB] - CargaContadores', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'src', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Carga Contadores', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpCarga_ContadoresSQL', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'mantem somente 7 dias', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM TaskenMaintDB.dbo.Registro_Contador where cast(Dt_Log as date) < cast(getdate()-7 as date)', 
		@database_name=N'TaskenMaintDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1 em 1 minuto', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20250704, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

----ANALISES
--LOG WHOISACTIVE
SELECT 
    [Dt_Log]
    ,[dd hh:mm:ss.mss]
    ,[database_name]
    ,[session_id]
    ,[blocking_session_id]
    ,CONVERT(NVARCHAR(MAX), [sql_text]) AS sql_text
    ,[login_name]
    ,[wait_info]
    ,[status]
    ,[percent_complete]
    ,[host_name]
    ,CONVERT(NVARCHAR(MAX), [sql_command]) AS sql_command
    ,[CPU]
    ,[reads]
    ,[writes]
    ,[Program_Name]
FROM 
    Resultado_WhoisActive 
order by 
    Dt_Log

--LOG Contadores
SELECT Nm_Contador,Dt_Log,Valor
FROM TaskenMaintDB..Contador A 
	JOIN TaskenMaintDB..Registro_Contador B ON A.Id_Contador = B.Id_Contador
ORDER BY DT_LOG
--BatchRequests = transações por segundo
--User_Connection = conexões no banco
--CPU = % consumo de cpu do servidor
--Page Life Expectancy: espectativa de vida em segundos de uma pagina na memoria do sql server (5000 = BOM / 1000 = RAZOAVEL / <300 = BAIXO)