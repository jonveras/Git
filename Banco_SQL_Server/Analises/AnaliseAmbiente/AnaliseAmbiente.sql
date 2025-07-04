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

-- ÝNDICES FRAGMENTADOS
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

-- ÝNDICES REDUNDANTES
WITH IndexColumns AS (
    SELECT 
        i.object_id,
        i.index_id,
        i.name AS index_name,
        i.type_desc,
        c.name AS column_name,
        ic.key_ordinal,
        ic.is_included_column
    FROM 
        sys.indexes i
        INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE 
        i.is_hypothetical = 0
),
IndexAgg AS (
    SELECT 
        object_id,
        index_id,
        MAX(index_name) AS index_name,
        MAX(type_desc) AS type_desc,
        STRING_AGG(CASE WHEN is_included_column = 0 THEN column_name END, ',') 
            WITHIN GROUP (ORDER BY key_ordinal) AS key_columns,
        STRING_AGG(CASE WHEN is_included_column = 1 THEN column_name END, ',') 
            WITHIN GROUP (ORDER BY key_ordinal) AS include_columns
    FROM 
        IndexColumns
    GROUP BY 
        object_id, index_id
)
SELECT 
    SCHEMA_NAME(o.schema_id) AS schema_name,
    OBJECT_NAME(ia1.object_id) AS table_name,
    ia1.index_name AS index1,
    ia2.index_name AS index2,
    ia1.type_desc AS type1,
    ia2.type_desc AS type2,
    ia1.key_columns,
    ia1.include_columns AS include_columns1,
    ia2.include_columns AS include_columns2,
    'DROP INDEX [' + ia2.index_name + '] ON [' + SCHEMA_NAME(o.schema_id) + '].[' + OBJECT_NAME(o.object_id) + ']' AS drop_statement
FROM 
    IndexAgg ia1
    INNER JOIN IndexAgg ia2 
        ON ia1.object_id = ia2.object_id
        AND ia1.index_id < ia2.index_id
        AND ia1.key_columns = ia2.key_columns
        AND ISNULL(ia1.include_columns, '') = ISNULL(ia2.include_columns, '')
        AND (
            ia1.type_desc = ia2.type_desc
            OR (ia1.type_desc = 'CLUSTERED' AND ia2.type_desc = 'NONCLUSTERED')
        )
    INNER JOIN sys.objects o ON ia1.object_id = o.object_id
ORDER BY 
    table_name, ia1.index_name;


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
SELECT 
    DB_NAME() AS DatabaseName,
    s.name AS SchemaName,
    o.name AS TableName,
    MAX(sp.last_updated) AS LastStatUpdate,
    COUNT(*) AS OutdatedStatsCount,
	STRING_AGG(stats.name, ', ') AS AffectedStatistics,
    'UPDATE STATISTICS [' + s.name + '].[' + o.name + '] WITH FULLSCAN;' AS UpdateStatisticsCommand
FROM 
    sys.stats AS stats
    CROSS APPLY sys.dm_db_stats_properties(stats.object_id, stats.stats_id) AS sp
    JOIN sys.objects o ON stats.object_id = o.object_id
    JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE 
    o.type = 'U' -- Apenas tabelas usuais
    AND (sp.modification_counter > 1000 -- Mudan�as relevantes
    OR (CAST(sp.rows_sampled AS FLOAT) / NULLIF(sp.rows, 0)) * 100 < 90 -- Amostragem ruim
    OR CAST(sp.last_updated AS DATE) <= GETDATE() - 3) -- Atualiza��o antiga
GROUP BY 
    s.name, o.name
ORDER BY 
    OutdatedStatsCount DESC;

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

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--	Query que mostra algumas sugest�o de �ndices para que possamos analisar a cria��o
SELECT 
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE NONCLUSTERED INDEX [SK01_'
 + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) +']'+ 

' ON ' + dm_mid.statement+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE
'' END+ ISNULL (dm_mid.inequality_columns, '')
+ ')'+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement,dm_migs.user_seeks,dm_migs.user_scans
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
and dm_migs.last_user_seek >= getdate()-1
ORDER BY Avg_Estimated_Impact DESC

----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//----------//

--	Essa query mostra a atualiza��o dos �ndices desde a �ltima vez que o SQL Server foi reiniciado. Como ainda n�o rodei nenhuma query, est� vazia.
select getdate(), o.Name,i.name, s.user_seeks,s.user_scans,s.user_lookups, s.user_Updates, 
	isnull(s.last_user_seek,isnull(s.last_user_scan,s.last_User_Lookup)) Ultimo_acesso,fill_factor
from sys.dm_db_index_usage_stats s
	 join sys.indexes i on i.object_id = s.object_id and i.index_id = s.index_id
	 join sys.sysobjects o on i.object_id = o.id
where s.database_id = db_id() --and o.name in ('TestesIndices') --and i.name = 'SK02_Telefone_Cliente'
order by s.user_seeks + s.user_scans + s.user_lookups desc