--Acha qual objeto contem o nome
SELECT 
    o.name AS objeto,
    o.type_desc AS tipo,
    s.name AS schema_nome,
    m.definition AS texto
FROM 
    sys.sql_modules m
JOIN 
    sys.objects o ON m.object_id = o.object_id
JOIN 
    sys.schemas s ON o.schema_id = s.schema_id
WHERE 
    m.definition LIKE '%objeto%'
ORDER BY 
    o.type_desc, o.name;

--Acha qual job contem o nome
SELECT 
    j.name AS nome_job,
    s.step_id,
    s.step_name,
    s.command
FROM 
    msdb.dbo.sysjobs j
JOIN 
    msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
WHERE 
    s.command LIKE '%objeto%'
ORDER BY 
    j.name, s.step_id;

-- acha a sessao do user
select * from sys.dm_exec_sessions where session_id > 50 and login_name 'dominio\usuario'


--VARRE TODOS OS BANCOS PROCURANDO PROCESSO

-- Texto que você quer procurar
DECLARE @TextoBusca NVARCHAR(200) = 'ANMN_ESTOQUE_HISTORICO_PROD_GRADE';

-- Cria tabela temporária para consolidar os resultados
IF OBJECT_ID('tempdb..#Resultados') IS NOT NULL DROP TABLE #Resultados;
CREATE TABLE #Resultados (
    Banco SYSNAME,
    Objeto SYSNAME,
    Tipo NVARCHAR(60),
    Esquema SYSNAME,
    Texto NVARCHAR(MAX)
);

DECLARE @Banco SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases
WHERE database_id > 4         -- Ignora master, model, msdb, tempdb
  AND state_desc = 'ONLINE';  -- Apenas bancos online

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @Banco;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Verificando banco: ' + @Banco;

    SET @SQL = N'
    USE [' + @Banco + '];
    INSERT INTO #Resultados (Banco, Objeto, Tipo, Esquema, Texto)
    SELECT 
        DB_NAME() AS Banco,
        o.name AS Objeto,
        o.type_desc AS Tipo,
        s.name AS Esquema,
        m.definition AS Texto
    FROM sys.sql_modules m
    JOIN sys.objects o ON m.object_id = o.object_id
    JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE m.definition LIKE N''%' + @TextoBusca + '%'';';

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @Banco;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Exibe os resultados consolidados
SELECT *
FROM #Resultados
ORDER BY Banco, Tipo, Objeto;
