IF OBJECT_ID('TEMPDB.DB.#Objects') IS NOT NULL
	DROP TABLE #Objects

-- Consulta para encontrar objetos que fazem UPDATE na tabela FATURAMENTO
SELECT 
    o.name AS ObjectName, 
    o.type_desc AS ObjectType
INTO #Objects  -- Armazenar os resultados em uma tabela temporária
FROM 
    sys.sql_modules m
JOIN 
    sys.objects o ON m.object_id = o.object_id
WHERE 
    m.definition LIKE '%UPDATE%' 
    AND m.definition LIKE '%FATURAMENTO%'
    AND o.name NOT LIKE '%bkp%'  -- Ignora objetos de backup
    AND o.type IN ('P', 'FN', 'IF', 'TF');  -- P = Stored Procedures, FN = Functions, IF = Inline Table Function, TF = Table-Valued Function


-- Consulta dinâmica para encontrar objetos em jobs no SQL Server Agent
DECLARE @sql AS NVARCHAR(MAX) = '';

-- Gerar o SQL dinâmico para procurar os objetos nos comandos dos jobs
SELECT @sql = @sql + '
    UNION ALL
    SELECT 
        ''' + o.ObjectName + ''',
        j.name AS JobName,
        s.step_id AS StepID,
        s.step_name AS StepName,
        s.command AS StepCommand
    FROM 
        msdb.dbo.sysjobs j
    JOIN 
        msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
    WHERE 
        s.command LIKE ''%' + o.ObjectName + '%'' 
        AND s.command LIKE ''%UPDATE%'' 
        AND s.command LIKE ''%FATURAMENTO%'' 
        AND s.command NOT LIKE ''%bkp%'';'
FROM #Objects o;

-- Executar o SQL gerado dinamicamente
SET @sql = STUFF(@sql, 1, 11, ''); -- Remove a primeira UNION ALL extra
EXEC sp_executesql @sql;