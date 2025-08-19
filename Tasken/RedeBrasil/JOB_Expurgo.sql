USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SRC - [22:00] - EXPURGO PONTUAL 1', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'REDEBRASIL\sistemasrc', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SRC - [22:00] - EXPURGO PONTUAL 1', @server_name = N'SRVDB001'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SRC - [22:00] - EXPURGO PONTUAL 1', @step_name=N'EXPURGO', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
					WHILE 1=1
					BEGIN
						IF (
								DATEPART(WEEKDAY, GETDATE()) BETWEEN 2 AND 6 -- segunda a sexta
								AND (
									DATEPART(HOUR, GETDATE()) >= 22
									OR DATEPART(HOUR, GETDATE()) < 6
								)
    						)
    
							BEGIN
								DELETE TOP (10000)
								FROM TBL_CONTROLE_RESULTADODISCAGEM_OLOS AS A
								JOIN CAD_DEVF AS B ON A.CONTRATO_FIN = B.CONTRATO_FIN
								WHERE B.DTENTRADA_FIN < ''2025-01-01 00:00:00.000''

								IF (@@ROWCOUNT <= 0)
								BEGIN
									BREAK;
								END
							END
						ELSE
						BEGIN
							BREAK; 
						END
					END' 
		,@database_name=N'SRC', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SRC - [22:00] - EXPURGO PONTUAL 1', 
		@enabled=0, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'REDEBRASIL\sistemasrc', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SRC - [22:00] - EXPURGO PONTUAL 1', @name=N'SEG A SEX', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20250815, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
