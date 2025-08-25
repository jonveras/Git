--CRIACAO DOS LOGS
--CRIACAO DA PROCEDURE DE CONTADORES E TABELAS
USE TaskenMaintDB
GO
--------------------------------------------------------------------------------------------------------------------------------
--	Cria��o da tabela de whoisactive
--------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Resultado_WhoisActive') IS NOT NULL
BEGIN
	DROP TABLE Resultado_WhoisActive
END

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
--	Criacao das tabelas para armazenar as informacoes
--------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('Contador') IS NOT NULL
BEGIN
	DROP TABLE Contador
END

IF OBJECT_ID('Registro_Contador') IS NOT NULL
BEGIN
	DROP TABLE Registro_Contador
END

CREATE TABLE Contador(Id_Contador INT identity, Nm_Contador VARCHAR(50))

INSERT INTO Contador (Nm_Contador)
SELECT 'BatchRequests'
INSERT INTO Contador (Nm_Contador)
SELECT 'User_Connection'
INSERT INTO Contador (Nm_Contador)
SELECT 'CPU'
INSERT INTO Contador (Nm_Contador)
SELECT 'Page Life Expectancy'
GO

CREATE TABLE [dbo].[Registro_Contador](
	[Id_Registro_Contador] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[Id_Contador] [int] NULL,
	[Valor] [int] NULL
) ON [PRIMARY]


--CRIA TABELA DE MEMORIA
CREATE TABLE Monitoramento_Memoria (
    DataHora DATETIME DEFAULT GETDATE(),
    
    -- Mem�ria do Servidor
    MemoriaTotalServidor_MB DECIMAL(10,2),
    MemoriaEmUsoServidor_MB DECIMAL(10,2),
    MemoriaDisponiveServidorl_MB DECIMAL(10,2),
    PorcentagemUtilizadaServidor DECIMAL(5,2)--,

    -- Mem�ria do processo SQL Server
    --MemoriaTotalSQL_MB DECIMAL(10,2),
    --MemoriaEmUsoSQL_MB DECIMAL(10,2),
    --MemoriaDisponiveSQL_MB DECIMAL(10,2),
    --PorcentagemUtilizadaSQL DECIMAL(5,2)
);
--------------------------------------------------------------------------------------------------------------------------------
--	Criacao da procedure para dar carga na tabela
--------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('stpCarga_ContadoresSQL') IS NOT NULL
BEGIN
	DROP PROCEDURE stpCarga_ContadoresSQL
END
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
GO

--PROCEDURE PARA COLETAR MEMORIA
CREATE PROCEDURE Coletar_Memoria
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    DECLARE   
        -- Servidor  
        @total_kb_server BIGINT,  
        @available_kb_server BIGINT,  
        @used_kb_server BIGINT,  
        @used_percent_server DECIMAL(5,2),  
  
        -- SQL Server  
        @sql_total_kb BIGINT,  
        @sql_used_kb BIGINT,  
        @sql_available_kb BIGINT,  
        @sql_percent_used DECIMAL(5,2);  
  
    -- Coletar dados de mem�ria do servidor  
    SELECT   
        @total_kb_server = total_physical_memory_kb,  
        @available_kb_server = available_physical_memory_kb  
    FROM sys.dm_os_sys_memory;  
  
    SET @used_kb_server = @total_kb_server - @available_kb_server;  
  
    SET @used_percent_server =   
        CASE   
            WHEN @total_kb_server > 0   
            THEN (CAST(@used_kb_server AS DECIMAL(18,2)) / @total_kb_server) * 100  
            ELSE 0  
        END;  
  
    ---- Coletar dados do processo SQL Server  
    --SELECT   
    --    @sql_used_kb = physical_memory_in_use_kb / 1024  
    --FROM sys.dm_os_process_memory;  
  
    ---- Obter o max server memory (em MB) e converter para KB  
    --SELECT   
    --    @sql_total_kb = CONVERT(BIGINT, value_in_use)  
    --FROM sys.configurations  
    --WHERE name = 'max server memory (MB)';  
  
    ---- Calcular dispon�vel e percentual  
    --SET @sql_available_kb = @sql_total_kb - @sql_used_kb;  
  
    --SET @sql_percent_used =   
    --    CASE   
    --        WHEN @sql_total_kb > 0   
    --        THEN (CAST(@sql_used_kb AS DECIMAL(18,2)) / @sql_total_kb) * 100  
    --        ELSE 0  
    --    END;  
  
    -- Inserir na tabela  
    INSERT INTO Monitoramento_Memoria (  
        DataHora,  
        MemoriaTotalServidor_MB,  
        MemoriaEmUsoServidor_MB,  
        MemoriaDisponiveServidorl_MB,  
        PorcentagemUtilizadaServidor
    )  
    VALUES (  
        GETDATE(),  
        @total_kb_server / 1024.0,  
        @used_kb_server / 1024.0,  
        @available_kb_server / 1024.0,  
        @used_percent_server
    );  
END;

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

--CRIAR JOB MEMORIA
CREATE PROCEDURE Coletar_Memoria
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        -- Servidor
        @total_kb_server BIGINT,
        @available_kb_server BIGINT,
        @used_kb_server BIGINT,
        @used_percent_server DECIMAL(5,2),

        -- SQL Server
        @sql_total_kb BIGINT,
        @sql_used_kb BIGINT,
        @sql_available_kb BIGINT,
        @sql_percent_used DECIMAL(5,2);

    -- Coletar dados de mem�ria do servidor
    SELECT 
        @total_kb_server = total_physical_memory_kb,
        @available_kb_server = available_physical_memory_kb
    FROM sys.dm_os_sys_memory;

    SET @used_kb_server = @total_kb_server - @available_kb_server;

    SET @used_percent_server = 
        CASE 
            WHEN @total_kb_server > 0 
            THEN (CAST(@used_kb_server AS DECIMAL(18,2)) / @total_kb_server) * 100
            ELSE 0
        END;

    -- Coletar dados do processo SQL Server
    SELECT 
        @sql_used_kb = physical_memory_in_use_kb / 1024
    FROM sys.dm_os_process_memory;

    -- Obter o max server memory (em MB) e converter para KB
    SELECT 
        @sql_total_kb = CONVERT(BIGINT, value_in_use)
    FROM sys.configurations
    WHERE name = 'max server memory (MB)';

    -- Calcular dispon�vel e percentual
    SET @sql_available_kb = @sql_total_kb - @sql_used_kb;

    SET @sql_percent_used = 
        CASE 
            WHEN @sql_total_kb > 0 
            THEN (CAST(@sql_used_kb AS DECIMAL(18,2)) / @sql_total_kb) * 100
            ELSE 0
        END;

    -- Inserir na tabela
    INSERT INTO Monitoramento_Memoria (
        DataHora,
        MemoriaTotalServidor_MB,
        MemoriaEmUsoServidor_MB,
        MemoriaDisponiveServidorl_MB,
        PorcentagemUtilizadaServidor,
        MemoriaTotalSQL_MB,
        MemoriaEmUsoSQL_MB,
        MemoriaDisponiveSQL_MB,
        PorcentagemUtilizadaSQL
    )
    VALUES (
        GETDATE(),
        @total_kb_server / 1024.0,
        @used_kb_server / 1024.0,
        @available_kb_server / 1024.0,
        @used_percent_server,
        @sql_total_kb,
        @sql_used_kb,
        @sql_available_kb,
        @sql_percent_used
    );
END;
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
--BatchRequests = transa��es por segundo
--User_Connection = conex�es no banco
--CPU = % consumo de cpu do servidor
--Page Life Expectancy: espectativa de vida em segundos de uma pagina na memoria do sql server (5000 = BOM / 1000 = RAZOAVEL / <300 = BAIXO)

SELECT * FROM Monitoramento_Memoria


------------------------------------------------------------------------------------------------///////
USE TaskenMaintDB; -- ou a base de administração que você preferir
GO

IF OBJECT_ID('dbo.Auditoria_MemoriaSQL') IS NULL
BEGIN
    CREATE TABLE dbo.Auditoria_MemoriaSQL
    (
        IdAuditoria       BIGINT IDENTITY PRIMARY KEY,
        DataColeta        DATETIME2 DEFAULT SYSDATETIME(),
        TotalServerMemoryMB   BIGINT,  -- memória que o SQL Server está usando
        TargetServerMemoryMB  BIGINT,  -- memória que o SQL gostaria de ter
        ProcessMemoryUsedMB   BIGINT,  -- memória usada pelo processo sqlservr.exe
        ProcessMemoryAvailMB  BIGINT,  -- memória disponível no processo
        OS_TotalMemoryMB      BIGINT,  -- memória física total do servidor
        OS_AvailableMemoryMB  BIGINT,  -- memória livre no SO
        PendingMemoryGrants   INT,     -- quantas queries aguardam grant
        ActiveMemoryGrants    INT,     -- quantas queries estão usando grant
        CachedPagesMB         BIGINT   -- páginas de buffer pool
    );
END
GO


CREATE OR ALTER PROCEDURE dbo.stp_ColetaMemoriaSQL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalMemoryMB BIGINT,
            @AvailableMemoryMB BIGINT;

    -- Informações do SO
    SELECT 
        @TotalMemoryMB = total_physical_memory_kb/1024,
        @AvailableMemoryMB = available_physical_memory_kb/1024
    FROM sys.dm_os_sys_memory;

    -- Inserção no log
    INSERT INTO dbo.Auditoria_MemoriaSQL
    (
        TotalServerMemoryMB,
        TargetServerMemoryMB,
        ProcessMemoryUsedMB,
        ProcessMemoryAvailMB,
        OS_TotalMemoryMB,
        OS_AvailableMemoryMB,
        PendingMemoryGrants,
        ActiveMemoryGrants,
        CachedPagesMB
    )
    SELECT 
        (SELECT cntr_value/1024 
         FROM sys.dm_os_performance_counters 
         WHERE counter_name = 'Total Server Memory (KB)' AND instance_name = '') AS TotalServerMemoryMB,
         
        (SELECT cntr_value/1024 
         FROM sys.dm_os_performance_counters 
         WHERE counter_name = 'Target Server Memory (KB)' AND instance_name = '') AS TargetServerMemoryMB,

        (pm.physical_memory_in_use_kb/1024) AS ProcessMemoryUsedMB,
        (pm.available_commit_limit_kb/1024) AS ProcessMemoryAvailMB,  -- disponível para o processo

        @TotalMemoryMB AS OS_TotalMemoryMB,
        @AvailableMemoryMB AS OS_AvailableMemoryMB,

        (SELECT COUNT(*) FROM sys.dm_exec_query_memory_grants WHERE grant_time IS NULL) AS PendingMemoryGrants,
        (SELECT COUNT(*) FROM sys.dm_exec_query_memory_grants WHERE grant_time IS NOT NULL) AS ActiveMemoryGrants,
        (SELECT COUNT(*)*8/1024 FROM sys.dm_os_buffer_descriptors) AS CachedPagesMB
    FROM sys.dm_os_process_memory pm;
END
GO

EXEC stp_ColetaMemoriaSQL

SELECT * FROM Auditoria_MemoriaSQL