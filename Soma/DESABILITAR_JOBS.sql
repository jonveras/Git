USE msdb;
GO

IF OBJECT_ID('ANALISETI.DBO.JOBS_DESABILITADOS') IS NOT NULL 
BEGIN
	DROP TABLE ANALISETI.DBO.JOBS_DESABILITADOS
END
  

SELECT
    'EXEC msdb.dbo.sp_update_job @job_name = N''' +
    REPLACE(J.name, '''', '''''') +
    ''', @enabled = 0;' AS COMANDO_DESABILITAR,
	'EXEC msdb.dbo.sp_update_job @job_name = N''' +
    REPLACE(J.name, '''', '''''') +
    ''', @enabled = 0;' AS COMANDO_HABILITAR,
	J.NAME AS JOB_NAME,
	C.name AS CATEGORY,
	GETDATE() AS [DATA]
INTO
	ANALISETI.DBO.JOBS_DESABILITADOS
FROM dbo.sysjobs AS J
INNER JOIN dbo.syscategories AS C
    ON J.category_id = C.category_id
WHERE J.enabled = 1
  AND C.name IN ('SOMA', 'DBViews','Logistica','Pitagoras')
ORDER BY C.name
OPTION (RECOMPILE);

SELECT
	*
FROM
	ANALISETI.DBO.JOBS_DESABILITADOS