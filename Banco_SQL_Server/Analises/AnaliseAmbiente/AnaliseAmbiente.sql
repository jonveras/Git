--Criar a sp_blitz para verificar a saúde do banco ()
EXEC sp_Blitz @CheckUserDatabaseObjects = 0;

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--VERIFICA ULTIMO RESTART DA INSTANCIA
SELECT sqlserver_start_time AS SQLServerStartTime
FROM sys.dm_os_sys_info;

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

-- TAMANHO EM MB POR BASE
SELECT
    db.name AS database_name,
    CAST(SUM(size) * 8.0 / 1024 AS DECIMAL(18,2)) AS total_size_mb
FROM
    sys.master_files mf
    INNER JOIN sys.databases db ON db.database_id = mf.database_id
GROUP BY
    db.name
ORDER BY
    total_size_mb DESC;

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--TOP 10 TABELAS MAIS PESADAS POR BASE
-- Gera um SELECT dinâmico para cada base de dados (exceto as de sistema)
DECLARE @SQL NVARCHAR(MAX) = N'';
SELECT @SQL += '
USE [' + name + '];
SELECT TOP 10
    DB_NAME() AS database_name,
    s.name AS schema_name,
    t.name AS table_name,
    p.rows AS row_count,
    CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(18,2)) AS total_size_mb
FROM 
    sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    i.type IN (0,1)  -- heap ou clustered
GROUP BY 
    s.name, t.name, p.rows
ORDER BY 
    total_size_mb DESC;

' 
FROM sys.databases
WHERE state_desc = 'ONLINE' AND name NOT IN ('master','model','msdb','tempdb');

-- Executa tudo de uma vez
EXEC sp_executesql @SQL;

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

-- ÍNDICES FRAGMENTADOS
SELECT TOP 100
	DB_NAME() AS DatabaseName,
    C.[name] AS TableName,
    B.[name] AS IndexName,
    A.index_type_desc AS IndexType,
    A.avg_fragmentation_in_percent
    --'ALTER INDEX [' + B.[name] + '] ON [' + D.[name] + '].[' + C.[name] + '] REBUILD' AS CmdRebuild
FROM
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')	A
    JOIN sys.indexes B ON B.[object_id] = A.[object_id] AND B.index_id = A.index_id
    JOIN sys.objects C ON B.[object_id] = C.[object_id]
    JOIN sys.schemas D ON D.[schema_id] = C.[schema_id]
WHERE
    A.avg_fragmentation_in_percent > 30
    AND OBJECT_NAME(B.[object_id]) NOT LIKE '[_]%'
    AND A.index_type_desc != 'HEAP'
ORDER BY
    A.avg_fragmentation_in_percent DESC

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

-- ÍNDICES REDUNDANTES
	WITH IndexColumns AS (
		SELECT 
			i.object_id,
			i.index_id,
			i.name AS index_name,
			i.type_desc AS index_type,
			ic.key_ordinal,
			c.name AS column_name
		FROM 
			sys.indexes i
		INNER JOIN 
			sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
		INNER JOIN 
			sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
		WHERE 
			i.is_hypothetical = 0
	),
	IndexAgg AS (
		SELECT 
			ic1.object_id,
			ic1.index_id,
			ic1.index_name,
			ic1.index_type,
			STRING_AGG(ic1.column_name, ',') WITHIN GROUP (ORDER BY ic1.key_ordinal) AS Columns
		FROM 
			IndexColumns ic1
		GROUP BY 
			ic1.object_id, ic1.index_id, ic1.index_name, ic1.index_type
	)
	SELECT 
		DB_NAME() AS DatabaseName,
		t.name AS TableName,
		ia1.index_name AS IndexName1,
		ia2.index_name AS IndexName2,
		ia1.index_type AS IndexType1,
		ia2.index_type AS IndexType2,
		ia1.Columns AS Columns1,
		ia2.Columns AS Columns2
	FROM 
		IndexAgg ia1
	JOIN 
		IndexAgg ia2 ON ia1.object_id = ia2.object_id AND ia1.index_id < ia2.index_id
	JOIN 
		sys.tables t ON t.object_id = ia1.object_id
	WHERE 
		ia1.Columns = ia2.Columns -- Índices exatamente iguais em colunas e ordem
	ORDER BY 
		t.name, ia1.index_name, ia2.index_name;

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--SUGESTÃO DE INDICE
SELECT
    mid.statement,
    migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans ) AS improvement_measure,
    OBJECT_NAME(mid.object_id),
    'CREATE INDEX [missing_index_' + CONVERT (VARCHAR, mig.index_group_handle) + '_' + CONVERT (VARCHAR, mid.index_handle) + '_' + LEFT(PARSENAME(mid.statement, 1), 32) + ']' + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
    migs.*,
    mid.database_id,
    mid.[object_id]
FROM
    sys.dm_db_missing_index_groups mig
    INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE
    migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans ) > 10
	AND mid.statement LIKE '%SRC_CALLCENTER%'
ORDER BY
    migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans ) DESC

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--ESTATISTICAS RUINS
SELECT TOP 100
    DB_NAME() AS DatabaseName,
    s.name AS SchemaName,
    o.name AS TableName,
    st.name AS StatisticName,
    stats.auto_created,
    stats.user_created,
    stats.no_recompute,
    stats.has_filter,
    sp.last_updated,
    sp.rows, -- TOTAL DE LINHAS DA TABELA QUANDO A ESTATISTICA FOI ATUALIZADA/CRIADA
    sp.rows_sampled, --SAMPLE UTILIZADO PARA ATUALIZAR/CRIAR O INDICE
    sp.modification_counter, --LINHAS MODIFICADAS DESDE A ULTIMA ATUALIZADA/CRIADA
    CASE 
        WHEN sp.rows > 0 THEN CAST(sp.rows_sampled AS FLOAT) / sp.rows * 100 
        ELSE 0 
    END AS SamplingRatePercent --PERCENTUAL DE LINHAS UTILIZADAS DESDE A ULTIMA ATUALIZAÇÃO/CRIAÇÃO
FROM 
    sys.stats AS stats
    CROSS APPLY sys.dm_db_stats_properties(stats.object_id, stats.stats_id) AS sp
    JOIN sys.objects o ON stats.object_id = o.object_id
    JOIN sys.schemas s ON o.schema_id = s.schema_id
    JOIN sys.stats st ON stats.object_id = st.object_id AND stats.stats_id = st.stats_id
WHERE 
    o.type = 'U' -- Apenas tabelas usuais
    AND sp.modification_counter > 1000 -- Mudanças relevantes desde última atualização
    AND (CAST(sp.rows_sampled AS FLOAT) / NULLIF(sp.rows, 0)) * 100 < 90 -- Amostragem ruim (< 90%)
	AND CAST(sp.last_updated AS DATE) <= GETDATE()-3
ORDER BY 
    sp.modification_counter DESC

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--UTILIZAÇÃO DE MEMÓRIA
SELECT 
    physical_memory_in_use_kb / 1024 AS SQLServerMemoryMB,
    large_page_allocations_kb / 1024 AS LargePageAllocMB,
    locked_page_allocations_kb / 1024 AS LockedPageAllocMB,
    total_virtual_address_space_kb / 1024 AS TotalVASMB,
    virtual_address_space_committed_kb / 1024 AS VASCommittedMB,
    page_fault_count,
    memory_utilization_percentage,
    available_commit_limit_kb / 1024 AS AvailableCommitLimitMB,
    process_physical_memory_low,
    process_virtual_memory_low
FROM sys.dm_os_process_memory;

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--JOBS
WITH JobHistorySummary AS (
    SELECT 
        job_id,
        COUNT(*) AS TotalRuns,
        SUM(CASE WHEN run_status = 1 THEN 1 ELSE 0 END) AS SuccessCount,
        SUM(CASE WHEN run_status != 1 THEN 1 ELSE 0 END) AS FailureCount,
        -- Corrigido: Convertendo para DATETIME corretamente
        MAX(CAST(CAST(run_date AS CHAR(8)) + ' ' + 
            STUFF(STUFF(RIGHT('000000' + CAST(run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME)) AS LastRunDateTime,
        AVG(CAST(run_duration AS INT)) AS AvgRunDuration
    FROM 
        msdb.dbo.sysjobhistory
    WHERE 
        step_id = 0
    GROUP BY 
        job_id
)
SELECT 
    j.name AS JobName,
    j.enabled AS IsEnabled,
    CASE 
        WHEN sc.freq_type = 1 THEN 'Uma Vez'
        WHEN sc.freq_type = 4 THEN 'Diario'
        WHEN sc.freq_type = 8 THEN 'Semanal'
        WHEN sc.freq_type = 16 THEN 'Mensal'
        ELSE 'Outro'
    END AS ScheduleType,
    CASE 
        WHEN j.enabled = 0 THEN 'Desativado (avaliar exclusão)'
        WHEN hs.TotalRuns IS NULL THEN 'Sem Histórico'
        WHEN hs.FailureCount > 0 AND hs.SuccessCount = 0 THEN 'Sempre falha'
        ELSE 'Ativo e executando'
    END AS Observacao
FROM 
    msdb.dbo.sysjobs j
LEFT JOIN 
    msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
LEFT JOIN 
    msdb.dbo.sysschedules sc ON js.schedule_id = sc.schedule_id
LEFT JOIN 
    JobHistorySummary hs ON j.job_id = hs.job_id
LEFT JOIN 
    msdb.dbo.syscategories c ON j.category_id = c.category_id
WHERE
	j.enabled = 0 OR hs.TotalRuns IS NULL OR (hs.FailureCount > 0 AND hs.SuccessCount = 0)
ORDER BY 
    Observacao DESC, hs.LastRunDateTime DESC;
