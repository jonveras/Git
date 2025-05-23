CREATE TABLE JobLogHistory (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    JobName SYSNAME,
    StepName SYSNAME,
    RunDate DATE,
    RunTime TIME(0),
    RunDuration TIME(0),
    RunStatus VARCHAR(50),
    Message NVARCHAR(4000),
    Created_At DATETIME DEFAULT GETDATE()
) 
GO

CREATE FUNCTION SplitString (
    @String NVARCHAR(MAX),
    @Delimiter CHAR(1)
)
RETURNS @Output TABLE (Value NVARCHAR(1000))
AS
/*************************************************************************************************                                                  
 * NOME DO OBJETO : SplitString                                                                   
 * CRIAÇÃO: 23/05/2025
 * PROFISSIONAL: JONATHAN VERAS
 * PROJETO: DEEPCENTER 
 * OBS: OBJETO UTILIZADO NA ExecucaoJobLogHistory                                                                    
 *************************************************************************************************/                                                  

BEGIN
    DECLARE @start INT = 1, @end INT;

    SET @String = @String + @Delimiter;

    WHILE CHARINDEX(@Delimiter, @String, @start) > 0
    BEGIN
        SET @end = CHARINDEX(@Delimiter, @String, @start);
        INSERT INTO @Output(Value)
        VALUES (LTRIM(RTRIM(SUBSTRING(@String, @start, @end - @start))));
        SET @start = @end + 1;
    END

    RETURN;
END 
GO

CREATE PROCEDURE ExecucaoJobLogHistory
    @JobNames NVARCHAR(MAX) = NULL 
AS
/*************************************************************************************************                                                  
 * NOME DO OBJETO : ExecucaoJobLogHistory                                                                   
 * CRIAÇÃO: 23/05/2025
 * PROFISSIONAL: JONATHAN VERAS
 * PROJETO: DEEPCENTER                                                                         
 *************************************************************************************************/                                                  

BEGIN
    SET NOCOUNT ON;

    
    DECLARE @JobNameTable TABLE (JobName SYSNAME);

    
    IF @JobNames IS NOT NULL
    BEGIN
        INSERT INTO @JobNameTable (JobName)
		SELECT Value FROM SplitString(@JobNames, ',');
    END

    BEGIN TRY
        INSERT INTO JobLogHistory (
            JobName, StepName, RunDate, RunTime, RunDuration, RunStatus, Message
        )
        SELECT 
            j.name AS JobName,
            h.step_name AS StepName,
            CONVERT(DATE, 
                CONCAT(
                    LEFT(h.run_date, 4), '-', 
                    SUBSTRING(CAST(h.run_date AS VARCHAR), 5, 2), '-', 
                    RIGHT(h.run_date, 2)
                )
            ) AS RunDate,
            STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS RunTime,
            TRY_CONVERT(TIME,
				RIGHT('00' + CAST(h.run_duration / 10000 AS VARCHAR), 2) + ':' +
				RIGHT('00' + CAST((h.run_duration % 10000) / 100 AS VARCHAR), 2) + ':' +
				RIGHT('00' + CAST(h.run_duration % 100 AS VARCHAR), 2)
			) AS RunDuration,
            CASE h.run_status
                WHEN 0 THEN 'Failed'
                WHEN 1 THEN 'Succeeded'
                WHEN 2 THEN 'Retry'
                WHEN 3 THEN 'Canceled'
                WHEN 4 THEN 'In Progress'
                ELSE 'Unknown'
            END AS RunStatus,
            h.message
        FROM 
            msdb.dbo.sysjobhistory h
            INNER JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
        WHERE 
            h.step_id > 0
			AND NOT EXISTS (SELECT 1 FROM JobLogHistory AS A WHERE CAST(CONCAT(A.JobName,A.RunDate,A.RunTime) AS VARCHAR) = CAST(CONCAT(j.name,
																																		CONVERT(DATE,CONCAT(LEFT(h.run_date, 4), '-',SUBSTRING(CAST(h.run_date AS VARCHAR), 5, 2), '-',RIGHT(h.run_date, 2))),
																																		STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
																																)AS VARCHAR)
			)
			AND CONVERT(DATETIME, 
				CONCAT(
					STUFF(STUFF(RIGHT('00000000' + CAST(h.run_date AS VARCHAR), 8), 5, 0, '-'), 8, 0, '-'), 
					' ', 
					STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR), 6), 3, 0, ':'), 6, 0, ':')
				)
			) >= DATEADD(DAY, -7, GETDATE())
            AND (
                @JobNames IS NULL 
                OR j.name IN (SELECT JobName FROM @JobNameTable)
            );

	DELETE FROM JobLogHistory
	WHERE RunDate < CAST(DATEADD(DAY, -7, GETDATE()) AS DATE);

    END TRY
    BEGIN CATCH
        EXEC STP_LOG_ERRO 'ExecucaoJobLogHistory'
    END CATCH
END 
GO

exec ExecucaoJobLogHistory 'SRC - DEEP - [12:00 | 22:00] - ExecucaoDeepCenterCarteiraTempoOperacional_NEW,SRC - DEEP - [15MIN] - ExecucaoDeepCenterBradescoComercialCrmDac_NEW,SRC - DEEP - [30MIN] - ExecucaoDeepCenterlBradescoComercialMulticanal_New'

select * from JobLogHistory

DROP PROC ExecucaoJobLogHistory
DROP TABLE JobLogHistory
DROP FUNCTION SplitString