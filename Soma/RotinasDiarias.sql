/*
Rotinas diárias:
1 - 000_0110_MIT_PROCESSAR_LF_ERROS_MIT_PROCESSAR_SPED

2 - Rodar o script abaixo para ajustar as estatisticas:
-- Atualizar os indices dos objetos
SELECT DISTINCT
	 sta.name
	,st.name
	,stp.rows
	,stp.rows_sampled
	,'UPDATE STATISTICS ' + '[' + ss.name + ']' + '.[' + OBJECT_NAME(st.object_id) + ']' + ' ' + '[' + st.name + ']' + ' WITH SAMPLE 85 PERCENT, MAXDOP=32'
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


--7 - mit_processa_livros
--8 - mit_processa_erros 
LX_LCF_TEMPORARIA_ENTRADAS
LX_LF_INTEGRA_SAIDA

*/