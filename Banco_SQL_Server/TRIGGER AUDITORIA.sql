USE [RM_LINX];
GO

IF OBJECT_ID('LOG_ALTERACAO_MAIS_VENDAS', 'U') IS NULL
BEGIN
    CREATE TABLE LOG_ALTERACAO_MAIS_VENDAS
    (
        AuditId           bigint IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_LOG PRIMARY KEY,
        AuditDateTime     datetime2(3) NOT NULL
            CONSTRAINT DF_LOG_AuditDateTime DEFAULT (GETDATE()),
        AuditAction       char(1) NOT NULL, -- I=Insert, U=Update, D=Delete
        CurrentLogin      sysname NOT NULL,
        HostName          varchar(128) NULL,
        ProgramName       varchar(128) NULL,
		TableName		  varchar(128) NULL,
        OldRowJson        varchar(max) NULL,
        NewRowJson        varchar(max) NULL
    );
END
GO

CREATE TRIGGER LXUID_LOG_ALTERACOES_VENDAS_POR_VENDEDOR
ON VENDAS_POR_VENDEDOR
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @cur_login  sysname       = SUSER_SNAME(),
        @host       nvarchar(128) = HOST_NAME(),
        @program    nvarchar(128) =  PROGRAM_NAME(),
		@STEP VARCHAR (10) = NULL,
		@NOMEJOB VARCHAR (100) = NULL;
	
	IF @cur_login IN ('ANIMALE\sql.admin')
	BEGIN
		--Pega os jobs que estão ativos e insere em uma tabela temporaria
		SELECT @program = program_name
		FROM sys.dm_exec_sessions
		WHERE session_id = @@SPID;
		--Pega os jobs que estão ativos e insere em uma tabela temporaria

		-- Pega qual é o job que fez a movimentação.
		DECLARE @IDJOB VARCHAR (100)
		DECLARE @JOBID VARCHAR(100)
	

		SELECT @STEP = LTRIM(RTRIM(SUBSTRING(@program,CHARINDEX(' STEP',@program), 7)))
		SELECT @JOBID = LTRIM(RTRIM(SUBSTRING(@program,PATINDEX('% 0X%',@program),CHARINDEX(':',@program)-PATINDEX('% 0X%',@program))))
		SELECT @IDJOB = CONVERT(UNIQUEIDENTIFIER,CONVERT(VARBINARY(16), @JOBID,1))

		SELECT 
			@NOMEJOB = [NAME] 
		FROM 
			MSDB.DBO.SYSJOBS 
		WHERE 
			JOB_ID = @IDJOB
		-- Pega qual é o job que fez a movimentação.
	END

    ;WITH [Changes] AS
    (
        SELECT
            CASE
                WHEN d.MATRICULA IS NULL THEN 'I'
                WHEN i.MATRICULA IS NULL THEN 'D'
                ELSE 'U'
            END AS AuditAction,
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS OldRowJson,
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS NewRowJson
        FROM inserted i
        FULL OUTER JOIN deleted d
            ON  i.MES_COMP      = d.MES_COMP
            AND i.ANO_COMP      = d.ANO_COMP
			AND i.ANM_CCOLIGADA = d.ANM_CCOLIGADA
			AND i.MATRICULA = d.MATRICULA
    )
    INSERT LOG_ALTERACAO_MAIS_VENDAS
    (
        AuditDateTime, AuditAction, CurrentLogin, HostName, ProgramName, TableName, OldRowJson, NewRowJson
    )
    SELECT
        sysdatetime(), AuditAction, @cur_login, @host, @program, 'VENDAS_POR_VENDEDOR', OldRowJson, NewRowJson
    FROM [Changes];
END
GO