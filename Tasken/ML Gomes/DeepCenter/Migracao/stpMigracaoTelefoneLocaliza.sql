CREATE PROCEDURE stpMigracaoTelefoneLocaliza(    
 @qtdtot int = 0 output    
)    
as    
BEGIN TRY    
    
DECLARE @OBJ VARCHAR(100) = 'stpMigracaoTelefoneLocaliza'    
DECLARE @DT_INI DATETIME, @DT_FIM DATETIME, @QTD INT = NULL    
    
-----------------------------------------------------------    
    
set @dt_ini = getdate()    
IF OBJECT_ID ('TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA') IS NOT NULL    
BEGIN    
 DROP TABLE TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA    
END;    
    
SELECT     
 B.CPF_DEV,    
 REPLACE(REPLACE(LEFT(B.TELEFONE,4),'(',''),')','') AS DDD_TEL,    
 SUBSTRING(REPLACE(B.TELEFONE,'-',''),5,10) AS TEL_TEL,    
    
 CASE B.[TIPOTELEFONE]    
  WHEN 'CELULAR'   THEN 4    
  WHEN 'CELULAR EXTRA' THEN 4    
  WHEN 'COMERCIAL'  THEN 2    
  WHEN 'FAX'    THEN 5    
  WHEN 'OUTROS'   THEN 7    
  WHEN 'PAGER'   THEN 5    
  WHEN 'PESQUISADO'  THEN 33    
  WHEN 'RESIDENCIAL'  THEN 1    
  ELSE 1    
 END AS COD_TIPO,    
 CASE     
  WHEN B.LISTANEGRA = 1 THEN 0    
  WHEN B.TIPO = 'AVALISTA' THEN 50    
  WHEN B.PRIORITARIO = 1 THEN 100    
  WHEN B.[STATUS] = 'EXCLUÍDO' THEN 0    
  WHEN B.[STATUS] = 'RUIM' THEN 10    
  WHEN B.[STATUS] = 'PESQ.' THEN 40    
  WHEN B.[STATUS] = 'NOVO' THEN 50    
  WHEN B.[STATUS] = 'BOM' THEN 70    
  ELSE 50    
 END AS PERC_TEL,    
 CASE    
  WHEN B.LISTANEGRA = 1 THEN 1    
  WHEN B.[STATUS] = 'EXCLUÍDO' THEN 1    
  ELSE 0    
 END AS STATUS_TEL, -- 0 = ATIVO | 1 - INATIVO    
    
 IIF(B.LISTANEGRA = 1, GETDATE(), NULL) AS DTNEGATIV_TEL,    
    
 IIF(B.PRIORITARIO = 1, 0, 1) AS PRIORIDADE_TEL, -- 0 = SIM | 1 - NÃO      
 'MIGRAÇÃO NEO - LOCALIZA' AS OBS_TEL,     
 B.DATAINCLUSAO AS DTINCLUSAO_TEL    
 INTO TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA    
FROM     
 NEO_ESPELHO_TELEFONES_LOCALIZA AS B WITH(NOLOCK)    
WHERE     
 CHARINDEX('(',B.TELEFONE) > 0 AND CHARINDEX(')',B.TELEFONE) > 0 AND CHARINDEX('-',B.TELEFONE) > 0 AND     
 EXISTS (SELECT * FROM SRC.DBO.CAD_DEV AS C WITH(NOLOCK)     
   WHERE B.CPF_DEV = C.CPF_DEV)    
--AND EXISTS (SELECT * FROM AUXSRC.DBO.TBL_CPFS_TESTE_MIGRACAO_LOCALIZA AS Z    
--     WHERE B.CPF_DEV = Z.CPF_DEV)    
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd    
    
/* **************************************************** UPDATE **************************************************** */    
    
set @dt_ini = getdate()    
IF OBJECT_ID ('TEMPDB.DBO.#TEMP_UPDATE_TELEFONES_MIGACAO') IS NOT NULL    
BEGIN    
 DROP TABLE #TEMP_UPDATE_TELEFONES_MIGACAO    
END;    
    
SELECT     
 X.CPF_DEV, Y.COD_TEL, Y.PERC_TEL, X.PERC_TEL AS PERC_TEL_NEO, X.STATUS_TEL,    
 ROW_NUMBER() OVER( ORDER BY X.CPF_DEV) AS ID    
 INTO #TEMP_UPDATE_TELEFONES_MIGACAO    
FROM     
 TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA AS X    
 JOIN SRC.DBO.CAD_DEVT AS Y WITH(NOLOCK) ON Y.CPF_DEV = X.CPF_DEV AND X.DDD_TEL = Y.DDD_TEL AND X.TEL_TEL = Y.TEL_TEL    
WHERE    
 Y.PERC_TEL <> X.PERC_TEL     
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, '#TEMP_UPDATE_TELEFONES_MIGACAO', @Dt_Ini, @Dt_Fim, @Qtd    
    
-------------------------------------------------------------------    
DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
SET @BLOCO = 1000    
    
if @Qtd > 0    
begin    
 set @dt_ini = getdate()    
    
 SET @VLR_INI = 1    
 SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
 SELECT @VLR_TOT = MAX(ID) FROM #TEMP_UPDATE_TELEFONES_MIGACAO    
    
 IF @VLR_TOT > 0     
 BEGIN    
  WHILE 1=1    
  BEGIN    
   UPDATE A SET    
    A.PERC_TEL = B.PERC_TEL_NEO    
   FROM    
    SRC.DBO.CAD_DEVT AS A    
    JOIN #TEMP_UPDATE_TELEFONES_MIGACAO AS B ON A.CPF_DEV = B.CPF_DEV AND A.COD_TEL = B.COD_TEL    
   WHERE    
    B.ID BETWEEN @VLR_INI AND @VLR_FIN    
    
   IF @VLR_FIN >= @VLR_TOT    
   BEGIN    
    BREAK    
   END    
    
   SET @VLR_INI += @BLOCO    
   SET @VLR_FIN += @BLOCO    
  END    
 END;    
    
 set @dt_fim = getdate()    
 exec stpLogTempoExecucao @obj, 'UPDATE PERC TELEFONES', @Dt_Ini, @Dt_Fim, @Qtd    
end;    
    
/* **************************************************** INSERT **************************************************** */    
    
set @dt_ini = getdate()    
IF OBJECT_ID ('tempdb.dbo.#TEMP_INSERT_TELEFONES_MIGACAO') IS NOT NULL    
BEGIN    
 DROP TABLE #TEMP_INSERT_TELEFONES_MIGACAO    
END;    
    
SELECT     
 CPF_DEV, DDD_TEL, TEL_TEL, COD_TIPO, PERC_TEL, STATUS_TEL, DTNEGATIV_TEL, PRIORIDADE_TEL, OBS_TEL, DTINCLUSAO_TEL,     
 ROW_NUMBER() OVER(PARTITION BY CPF_DEV ORDER BY CPF_DEV)+    
 COALESCE((SELECT MAX(Z.COD_TEL) FROM SRC.DBO.CAD_DEVT AS Z WITH(NOLOCK)     
    WHERE Z.CPF_DEV = X.CPF_DEV),0)         AS COD_TEL,    
 ROW_NUMBER() OVER( ORDER BY CPF_DEV) AS ID    
 INTO #TEMP_INSERT_TELEFONES_MIGACAO    
FROM     
 TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA AS X    
WHERE    
 NOT EXISTS (SELECT * FROM SRC.DBO.CAD_DEVT AS Y WITH(NOLOCK)    
    WHERE Y.CPF_DEV = X.CPF_DEV AND X.DDD_TEL = Y.DDD_TEL AND X.TEL_TEL = Y.TEL_TEL)    
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, '#TEMP_INSERT_TELEFONES_MIGACAO', @Dt_Ini, @Dt_Fim, @Qtd    
    
-------------------------------------------------------------------    
if @Qtd > 0    
begin    
    
 set @dt_ini = getdate()    
 --DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
    
 SET @VLR_INI = 1    
 SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
 SELECT @VLR_TOT = MAX(ID) FROM #TEMP_INSERT_TELEFONES_MIGACAO    
    
 IF @VLR_TOT > 0     
 BEGIN    
  WHILE 1=1    
  BEGIN    
   INSERT SRC.DBO.CAD_DEVT (    
    CPF_DEV, DDD_TEL, TEL_TEL, COD_TIPO, PERC_TEL, STATUS_TEL, DTNEGATIV_TEL, PRIORIDADE_TEL, OBS_TEL, DTINCLUSAO_TEL, COD_TEL    
   )    
   SELECT CPF_DEV, DDD_TEL, TEL_TEL, COD_TIPO, PERC_TEL, STATUS_TEL, DTNEGATIV_TEL, PRIORIDADE_TEL, OBS_TEL, DTINCLUSAO_TEL, COD_TEL    
   FROM #TEMP_INSERT_TELEFONES_MIGACAO AS X    
   WHERE ID BETWEEN @VLR_INI AND @VLR_FIN    
    
   INSERT SRC.DBO.AUX_DEVT ( CPF_DEV, COD_TEL, COD_RECUP_INC_ALTER )    
   SELECT CPF_DEV, COD_TEL, 377 FROM #TEMP_INSERT_TELEFONES_MIGACAO AS X     
   WHERE X.ID BETWEEN @VLR_INI AND @VLR_FIN     
   AND NOT EXISTS (SELECT * FROM SRC.DBO.AUX_DEVT AS Y WITH(NOLOCK) WHERE X.CPF_DEV = Y.CPF_DEV AND X.COD_TEL = Y.COD_TEL)    
    
   IF @VLR_FIN >= @VLR_TOT    
   BEGIN    
    BREAK    
   END    
    
   SET @VLR_INI += @BLOCO    
   SET @VLR_FIN += @BLOCO    
  END    
 END;    
    
 set @dt_fim = getdate()    
 exec stpLogTempoExecucao @obj, 'INSERT TELEFONES', @Dt_Ini, @Dt_Fim, @Qtd    
end;    
    
/* **************************************************** AUX_DEVT **************************************************** */    
/*    
IF OBJECT_ID ('tempdb.dbo.#TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVT') IS NOT NULL    
BEGIN    
 DROP TABLE #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVT    
END;    
    
SELECT     
 Y.CPF_DEV, Y.COD_TEL, ROW_NUMBER() OVER(ORDER BY CPF_DEV) AS ID    
 INTO #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVT    
FROM     
 TBL_TEMP_MIGRACAO_TELEFONES_NEO_LOCALIZA AS X WITH(NOLOCK)    
 JOIN SRC.DBO.CAD_DEVT AS Y WITH(NOLOCK) ON Y.CPF_DEV = X.CPF_DEV AND X.DDD_TEL = Y.DDD_TEL AND X.TEL_TEL = Y.TEL_TEL    
WHERE    
 NOT EXISTS (SELECT * FROM SRC.DBO.AUX_DEVT AS Z WITH(NOLOCK)     
    WHERE Y.CPF_DEV = Z.CPF_DEV AND Y.COD_TEL = Z.COD_TEL)    
    
-------------------------------------------------------------------    
    
DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
    
SET @BLOCO = 1000    
    
SET @VLR_INI = 1    
SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
SELECT @VLR_TOT = MAX(ID) FROM #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVT    
    
IF @VLR_TOT > 0     
BEGIN    
 WHILE 1=1    
 BEGIN    
  INSERT SRC.DBO.AUX_DEVT ( CPF_DEV, COD_TEL, COD_RECUP_INC_ALTER )    
  SELECT CPF_DEV, COD_TEL, 377 FROM #TEMP_INSERT_TELEFONES_MIGACAO AS X WHERE ID BETWEEN @VLR_INI AND @VLR_FIN    
    
  IF @VLR_FIN >= @VLR_TOT    
  BEGIN    
   BREAK    
  END    
    
  SET @VLR_INI += @BLOCO    
  SET @VLR_FIN += @BLOCO    
 END    
END;    
*/    
    
/* **************************************************** BLACKLIST **************************************************** */    
    
set @dt_ini = getdate()    
INSERT SRC.DBO.CAD_BLACKLIST_TELEFONES (    
 CPF_DEV, DDD_TEL, TEL_TEL, DATA_INCLUSAO    
)    
SELECT *    
FROM (    
 SELECT     
  CPF_DEV,    
  REPLACE(REPLACE(LEFT(TELEFONE,4),'(',''),')','') AS DDD_TEL,    
  SUBSTRING(REPLACE(TELEFONE,'-',''),5,10) AS TEL_TEL,    
  GETDATE() AS DATA_INCLUSAO    
 FROM     
  NEO_ESPELHO_TELEFONES_LOCALIZA  as b WITH(NOLOCK)    
 WHERE     
  LISTANEGRA = 1    
 --AND EXISTS (SELECT * FROM AUXSRC.DBO.TBL_CPFS_TESTE_MIGRACAO_LOCALIZA AS Z    
 --     WHERE B.CPF_DEV = Z.CPF_DEV)    
) AS X    
WHERE    
 NOT EXISTS (SELECT * FROM SRC.DBO.CAD_BLACKLIST_TELEFONES AS Y WITH(NOLOCK)    
    WHERE Y.CPF_DEV = X.CPF_DEV AND X.DDD_TEL = Y.DDD_TEL AND X.TEL_TEL = Y.TEL_TEL)    
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'BLACKLIST TELEFONES', @Dt_Ini, @Dt_Fim, @Qtd    
    
end try    
begin catch    
 EXEC STP_LOG_ERRO 'stpMigracaoTelefoneLocaliza'    
 SELECT      
    ERROR_NUMBER() AS ERRORNUMBER        
   ,ERROR_SEVERITY() AS ERRORSEVERITY        
   ,ERROR_STATE() AS ERRORSTATE        
   ,ERROR_PROCEDURE() AS ERRORPROCEDURE        
   ,ERROR_LINE() AS ERRORLINE        
   ,ERROR_MESSAGE() AS ERRORMESSAGE;      
end catch