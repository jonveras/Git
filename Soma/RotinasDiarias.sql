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


/* =====================================================================
   ROTINA DA MANHA - ESTATISTICAS ABAIXO DO ALVO
   Base SOMA | somente leitura | nao cria nem altera nada
 
   Resultado 1 : resumo - quanto trabalho existe hoje
   Resultado 2 : PRIORIDADE - as 4 procs criticas, indice primeiro
   Resultado 3 : o resto do SOMA - so se sobrar tempo
 
   Os comandos vem prontos na ultima coluna. Sao TEXTO: nada executa
   ate voce copiar, colar e mandar rodar.
   ===================================================================== */
USE SOMA;
SET NOCOUNT ON;
 
DECLARE @Amostra       int           = 85,        -- amostragem a aplicar
        @Alvo          decimal(5,2)  = 80.00,     -- abaixo disso entra na lista
        @Maxdop        int           = 28,
        @LinhasMinimas bigint        = 100000,    -- ignora tabela pequena
        @MaxNivel      int           = 3;
 
/* ---------------------------------------------------------------------
   1. Tabelas alcancadas pelas 4 procs criticas (expansao recursiva)
   --------------------------------------------------------------------- */
IF OBJECT_ID('tempdb..#Obj')   IS NOT NULL DROP TABLE #Obj;
IF OBJECT_ID('tempdb..#Novos') IS NOT NULL DROP TABLE #Novos;
IF OBJECT_ID('tempdb..#Fila')  IS NOT NULL DROP TABLE #Fila;
 
CREATE TABLE #Obj (
    nome       nvarchar(300) NOT NULL PRIMARY KEY,
    tipo       char(2)       NOT NULL,
    object_id  int           NOT NULL,
    nivel      int           NOT NULL,
    processado bit           NOT NULL
);
CREATE TABLE #Novos (
    nome nvarchar(300) NOT NULL, tipo char(2) NOT NULL,
    object_id int NOT NULL, nivel int NOT NULL
);
 
INSERT INTO #Obj (nome, tipo, object_id, nivel, processado)
SELECT DISTINCT
       QUOTENAME(OBJECT_SCHEMA_NAME(o.object_id)) + N'.' + QUOTENAME(o.name),
       o.type, o.object_id, 0, 0
FROM   (VALUES ('dbo.LX_CTB_INTEGRAR_ENTRADA'),
               ('dbo.lx_gera_nfe_sefaz_4_00'),
               ('dbo.PROC_GS_GERA_NFE_FATURAMENTO_AUTO_PA'),
               ('dbo.FX_MONTA_CARDEX_PA_DATA')) AS p(nome)
JOIN   sys.objects AS o ON o.object_id = OBJECT_ID(p.nome);
 
DECLARE @nome nvarchar(300), @nivel int;
 
WHILE EXISTS (SELECT 1 FROM #Obj WHERE processado = 0 AND nivel < @MaxNivel AND tipo <> 'U ')
BEGIN
    SELECT TOP (1) @nome = nome, @nivel = nivel
    FROM   #Obj
    WHERE  processado = 0 AND nivel < @MaxNivel AND tipo <> 'U '
    ORDER BY nivel, nome;
 
    DELETE FROM #Novos;
 
    BEGIN TRY
        INSERT INTO #Novos (nome, tipo, object_id, nivel)
        SELECT DISTINCT
               QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.' + QUOTENAME(o.name),
               o.type, o.object_id, @nivel + 1
        FROM   sys.dm_sql_referenced_entities(@nome, 'OBJECT') AS d
        JOIN   sys.objects AS o ON o.object_id = d.referenced_id
        WHERE  d.referenced_id            IS NOT NULL
          AND  d.referenced_server_name   IS NULL
          AND  d.referenced_database_name IS NULL
          AND  o.type IN ('U ', 'V ', 'P ', 'FN', 'IF', 'TF');
    END TRY
    BEGIN CATCH
        PRINT '  aviso: nao expandiu ' + @nome + ' -> ' + ERROR_MESSAGE();
    END CATCH;
 
    INSERT INTO #Obj (nome, tipo, object_id, nivel, processado)
    SELECT n.nome, n.tipo, n.object_id, n.nivel, 0
    FROM   #Novos AS n
    WHERE  NOT EXISTS (SELECT 1 FROM #Obj AS o WHERE o.nome = n.nome);
 
    UPDATE #Obj SET processado = 1 WHERE nome = @nome;
END;
 
/* ---------------------------------------------------------------------
   2. Fila pendente do PowerStats (informativo)
   --------------------------------------------------------------------- */
SELECT DISTINCT
       esquema = PARSENAME(q.Fqn, 2),
       tabela  = PARSENAME(q.Fqn, 1),
       q.StatsName
INTO   #Fila
FROM   Traces.dbo.PowerStats_CommandQueue AS q
WHERE  q.DatabaseName = 'SOMA'
  AND  q.ParentStartTime >= DATEADD(hour, -36, SYSDATETIME())
  AND  ISNULL(q.ExecStatus, 'pending') IN ('pending', 'running');
 
/* =====================================================================
   RESULTADO 1 - RESUMO
   ===================================================================== */
;WITH tudo AS (
    SELECT  eh_proc  = CASE WHEN EXISTS (SELECT 1 FROM #Obj AS ob
                                         WHERE ob.object_id = t.object_id AND ob.tipo = 'U ')
                            THEN 1 ELSE 0 END,
            eh_indice = CASE WHEN i.index_id IS NOT NULL THEN 1 ELSE 0 END,
            sp.rows
    FROM    sys.tables  AS t
    JOIN    sys.schemas AS ss ON ss.schema_id = t.schema_id
    JOIN    sys.stats   AS st ON st.object_id = t.object_id
    LEFT JOIN sys.indexes AS i ON i.object_id = st.object_id AND i.index_id = st.stats_id
    CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
    WHERE   t.is_ms_shipped = 0
      AND   sp.rows IS NOT NULL
      AND   sp.rows >= @LinhasMinimas
      AND   CAST(100.0 * sp.rows_sampled / NULLIF(sp.rows, 0) AS decimal(5,2)) < @Alvo
)
SELECT  escopo        = CASE WHEN eh_proc = 1 THEN '1 - PROCS CRITICAS' ELSE '2 - RESTO DO SOMA' END,
        tipo          = CASE WHEN eh_indice = 1 THEN 'INDICE' ELSE 'COLUNA' END,
        estatisticas  = COUNT(*),
        custo_total_mi = CAST(SUM(rows * 0.85) / 1000000.0 AS decimal(14,1))
FROM    tudo
GROUP BY eh_proc, eh_indice
ORDER BY escopo, tipo
OPTION (RECOMPILE);
 
/* =====================================================================
   RESULTADO 2 - PRIORIDADE: as 4 procs criticas
   Indice primeiro, depois coluna; dentro de cada bloco, maior primeiro.
   Pare quando "acumulado_mi" chegar no limite da sua janela.
   ===================================================================== */
SELECT  ordem        = CASE WHEN i.index_id IS NOT NULL THEN '1-INDICE' ELSE '2-COLUNA' END,
        tabela       = ss.name + '.' + t.name,
        estatistica  = st.name,
        sp.rows,
        pct          = CAST(100.0 * sp.rows_sampled / NULLIF(sp.rows, 0) AS decimal(5,2)),
        sp.modification_counter,
        sp.last_updated,
        custo_mi     = CAST(sp.rows * 0.85 / 1000000.0 AS decimal(12,1)),
        acumulado_mi = CAST(SUM(sp.rows * 0.85) OVER (
                              ORDER BY CASE WHEN i.index_id IS NOT NULL THEN 0 ELSE 1 END,
                                       sp.rows DESC, st.name
                              ROWS UNBOUNDED PRECEDING) / 1000000.0 AS decimal(14,1)),
        na_fila      = CASE WHEN f.StatsName IS NOT NULL
                            THEN 'sim - o job pega hoje a noite'
                            ELSE 'NAO - fora do escopo, so voce' END,
        comando      = N'UPDATE STATISTICS ' + QUOTENAME(ss.name) + N'.' + QUOTENAME(t.name)
                     + N' ' + QUOTENAME(st.name)
                     + N' WITH SAMPLE ' + CAST(@Amostra AS nvarchar(3)) + N' PERCENT'
                     + N', MAXDOP = ' + CAST(@Maxdop AS nvarchar(3)) + N';'
FROM    #Obj AS ob
JOIN    sys.tables  AS t  ON t.object_id  = ob.object_id AND ob.tipo = 'U '
JOIN    sys.schemas AS ss ON ss.schema_id = t.schema_id
JOIN    sys.stats   AS st ON st.object_id = t.object_id
LEFT JOIN sys.indexes AS i ON i.object_id = st.object_id AND i.index_id = st.stats_id
LEFT JOIN #Fila       AS f ON f.esquema = ss.name AND f.tabela = t.name AND f.StatsName = st.name
CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
WHERE   sp.rows IS NOT NULL
  AND   sp.rows >= @LinhasMinimas
  AND   CAST(100.0 * sp.rows_sampled / NULLIF(sp.rows, 0) AS decimal(5,2)) < @Alvo
ORDER BY CASE WHEN i.index_id IS NOT NULL THEN 0 ELSE 1 END, sp.rows DESC, st.name
OPTION (RECOMPILE);
 
/* =====================================================================
   RESULTADO 3 - O RESTO DO SOMA (so se sobrar tempo)
   "NAO - fora do escopo" = ninguem alem de voce corrige.
   ===================================================================== */
SELECT TOP (60)
        tabela       = ss.name + '.' + t.name,
        estatistica  = st.name,
        tipo         = CASE WHEN i.index_id IS NOT NULL THEN 'INDICE' ELSE 'COLUNA' END,
        sp.rows,
        pct          = CAST(100.0 * sp.rows_sampled / NULLIF(sp.rows, 0) AS decimal(5,2)),
        sp.modification_counter,
        sp.last_updated,
        dias         = DATEDIFF(day, sp.last_updated, SYSDATETIME()),
        custo_mi     = CAST(sp.rows * 0.85 / 1000000.0 AS decimal(12,1)),
        na_fila      = CASE WHEN f.StatsName IS NOT NULL
                            THEN 'sim'
                            ELSE 'NAO - fora do escopo, so voce' END,
        comando      = N'UPDATE STATISTICS ' + QUOTENAME(ss.name) + N'.' + QUOTENAME(t.name)
                     + N' ' + QUOTENAME(st.name)
                     + N' WITH SAMPLE ' + CAST(@Amostra AS nvarchar(3)) + N' PERCENT'
                     + N', MAXDOP = ' + CAST(@Maxdop AS nvarchar(3)) + N';'
FROM    sys.tables  AS t
JOIN    sys.schemas AS ss ON ss.schema_id = t.schema_id
JOIN    sys.stats   AS st ON st.object_id = t.object_id
LEFT JOIN sys.indexes AS i ON i.object_id = st.object_id AND i.index_id = st.stats_id
LEFT JOIN #Fila       AS f ON f.esquema = ss.name AND f.tabela = t.name AND f.StatsName = st.name
CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
WHERE   t.is_ms_shipped = 0
  AND   NOT EXISTS (SELECT 1 FROM #Obj AS ob
                    WHERE ob.object_id = t.object_id AND ob.tipo = 'U ')
  AND   sp.rows IS NOT NULL
  AND   sp.rows >= 1000000
  AND   CAST(100.0 * sp.rows_sampled / NULLIF(sp.rows, 0) AS decimal(5,2)) < @Alvo
ORDER BY sp.rows DESC
OPTION (RECOMPILE);
*/