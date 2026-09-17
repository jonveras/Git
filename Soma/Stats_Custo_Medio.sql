USE SOMA
GO

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
			FROM sys.dm_sql_referenced_entities('dbo.LX_CM_FECHAMENTO_CUSTO_MEDIO','OBJECT') d
			JOIN sys.objects o ON d.referenced_id = o.[object_id]
			WHERE o.[type] IN ('U','V')
		)
ORDER BY rows DESC
OPTION (RECOMPILE)

--> Passos do Custo Medio
--1. LX_CM_FECHAMENTO_CUSTO_MEDIO
	--1.1. LX_CM_FECHAMENTO_CUSTO_MEDIO_OE_INCIAL
	--1.2. LX_CM_PRODUCAO_RECURSO
	--1.3. LX_CM_COMPOSICAO_CUSTO_MP
		--1.3.1. LX_CM_COMPOSICAO_CUSTO_MP_OE -- Ponderacoes: Ajustar a tabela CSM_AJUSTE_028_MP (coluna MATERIAL esta VARCHAR(12), mas o material é CHAR(11), coluna COD_CUSTO_MEDIO VARCHAR(10), mas o COD é CHAR(8))
	--1.4. LX_CM_CUSTO_MP
		--1.4.1. LX_CM_CUSTO_MP_OE
	--1.5. LX_GS_CM_CUSTO_MP_ZERADOS -- Ponderacoes: Validar O LEFT JOIN repetitivo (ok)
		--1.5.1 - LX_CM_PRODUCAO_PA -- Ponderacoes: Trecho mais custoso está aqui
			--1.5.1.1 - LX_CM_PRODUCAO_PA_PROCESSO
	--1.6. LX_CM_COMPOSICAO_CUSTO_PA
		--1.6.1 - LX_CM_COMPOSICAO_CUSTO_PA_OE
	--1.7. LX_CM_CUSTO_PA -- Ponderacao: Colocar GETDATE() na atualizacao do Estoque_Produto pra evitar trigger e ganhar tempo
	--1.8. LX_GS_CM_CUSTO_PA_ZERADOS

