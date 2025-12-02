-- PARTE 1
-- ANÁLISE COMPLETA DE USO DE TABELAS NO SQL SERVER
-- Combina estrutura + dados + estatísticas de uso
SET NOCOUNT ON;

CREATE TABLE #TableUsageAnalysis (
 DatabaseName NVARCHAR(128),
 SchemaName NVARCHAR(128),
 TableName NVARCHAR(128),
 DaysSinceStructureChange INT,
 DaysSinceLastRead INT,
 DaysSinceLastWrite INT,
 TotalReads BIGINT,
 TotalWrites BIGINT,
 HasIndexes BIT,
 TableSizeMB DECIMAL(18,2)
);

DECLARE @DatabaseName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);
DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases 
WHERE state_desc = 'ONLINE' 
AND name NOT IN ('master','tempdb','model','msdb')
AND database_id > 4; -- Apenas bancos de usuário
 
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
 SET @SQL = '
 USE ' + QUOTENAME(@DatabaseName) + ';

 INSERT INTO #TableUsageAnalysis 
 SELECT 
 ''' + @DatabaseName + ''' AS DatabaseName,
 s.name AS SchemaName,
 t.name AS TableName,
 DATEDIFF(DAY, t.modify_date, GETDATE()) AS DaysSinceStructureChange,
 CASE 
 WHEN us.last_user_seek IS NULL AND us.last_user_scan IS NULL AND us.last_user_lookup IS NULL 
 THEN NULL
 ELSE DATEDIFF(DAY, 
 COALESCE(us.last_user_seek, us.last_user_scan, us.last_user_lookup), 
 GETDATE())
 END AS DaysSinceLastRead,
 DATEDIFF(DAY, us.last_user_update, GETDATE()) AS DaysSinceLastWrite,
 (ISNULL(us.user_seeks, 0) + ISNULL(us.user_scans, 0) + ISNULL(us.user_lookups, 0)) AS TotalReads, ISNULL(us.user_updates, 0) AS TotalWrites,
 CASE WHEN i.index_id IS NOT NULL THEN 1 ELSE 0 END AS HasIndexes,
 (SUM(a.total_pages) * 8) / 1024.0 AS TableSizeMB
 FROM sys.tables t
 INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
 LEFT JOIN sys.dm_db_index_usage_stats us 
 ON us.object_id = t.object_id AND us.database_id = DB_ID()
 LEFT JOIN sys.indexes i ON t.object_id = i.object_id
 LEFT JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
 LEFT JOIN sys.allocation_units a ON p.partition_id = a.container_id
 WHERE t.is_ms_shipped = 0
 GROUP BY s.name, t.name, t.modify_date, us.last_user_seek, us.last_user_scan, 
 us.last_user_lookup, us.last_user_update, us.user_seeks, us.user_scans,
 us.user_lookups, us.user_updates, i.index_id
 ';
 
 BEGIN TRY
 EXEC sp_executesql @SQL;
 END TRY
 BEGIN CATCH
 PRINT 'Erro no database ' + @DatabaseName + ': ' + ERROR_MESSAGE();
 END CATCH
 
 FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- PARTE 4
-- RESULTADO FINAL COM ANÁLISE COMPLETA
SELECT 
 DatabaseName AS [Banco de Dados],
 SchemaName AS [Schema],
 TableName AS [Tabela],
 DaysSinceStructureChange AS [Dias sem alteração estrutural],
 DaysSinceLastRead AS [Dias sem leitura],
 DaysSinceLastWrite AS [Dias sem gravação],
 TotalReads AS [Total de Leituras],
 TotalWrites AS [Total de Gravações],
 HasIndexes AS [Possui Índices],
 TableSizeMB AS [Tamanho (MB)],
 CASE 
 WHEN DaysSinceLastRead > 365 AND DaysSinceLastWrite > 365 THEN 'Candidata a arquivamento'
 WHEN DaysSinceLastRead > 180 AND DaysSinceLastWrite > 180 THEN 'Baixo uso - Monitorar'
 WHEN TotalReads = 0 AND TotalWrites = 0 THEN 'Nunca utilizada'
 ELSE 'Em uso ativo'
 END AS [Status Recomendação]
FROM #TableUsageAnalysis
where
	TotalReads = 0 AND TotalWrites = 0
ORDER BY 
 DaysSinceLastRead DESC,
 DaysSinceLastWrite DESC,
 TableSizeMB DESC;

--DROP TABLE #TableUsageAnalysis;