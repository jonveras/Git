-- Se a diferença entre amostra e quantidade de dados for muito grande, podemos fazer a atualizacao com fullscan
SELECT DISTINCT
	 sta.name
	,st.name
	,stp.rows
	,stp.rows_sampled
	,'UPDATE STATISTICS ' + '[' + ss.name + ']' + '.[' + OBJECT_NAME(st.object_id) + ']' + ' ' + '[' + st.name + ']' + ' WITH FULLSCAN, MAXDOP=32'
FROM sys.stats AS st
CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS stp
INNER JOIN sys.tables as sta ON st.object_id = sta.object_id
INNER JOIN sys.schemas AS ss ON ss.schema_id = sta.schema_id
WHERE	1=1
		AND rows <> rows_sampled
		--AND sta.name LIKE 'venda%'
		AND sta.name IN (
			SELECT DISTINCT	o.name
			FROM sys.dm_sql_referenced_entities('dbo.LX_CTB_INTEGRAR_ENTRADA','OBJECT') d
			JOIN sys.objects o ON d.referenced_id = o.[object_id]
			WHERE o.[type] IN ('U','V')
		)
ORDER BY rows DESC
OPTION (RECOMPILE)