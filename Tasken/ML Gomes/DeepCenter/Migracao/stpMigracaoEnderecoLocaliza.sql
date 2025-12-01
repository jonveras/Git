    
CREATE PROCEDURE stpMigracaoEnderecoLocaliza(    
 @qtdtot int = 0 output    
)    
as    
BEGIN TRY    
    
DECLARE @OBJ VARCHAR(100) = 'stpMigracaoEnderecoLocaliza'    
DECLARE @DT_INI DATETIME, @DT_FIM DATETIME, @QTD INT = NULL    
    
-----------------------------------------------------------    
    
set @dt_ini = getdate()    
IF OBJECT_ID ('TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA') IS NOT NULL    
BEGIN    
 DROP TABLE TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA    
END;    
    
SELECT     
 B.CPF_DEV,    
 RTRIM(LTRIM(B.ENDERECO))     AS RUA_END,    
 RTRIM(LTRIM(B.BAIRRO))      AS BAIRRO_END,    
 RTRIM(LTRIM(B.CIDADE))      AS CIDADE_END,    
 C.COD_UF,    
 RTRIM(LTRIM(B.CEP))       AS CEP_END,    
 RTRIM(LTRIM(B.NUMERO))      AS NUM_END,    
 LEFT(RTRIM(LTRIM(B.COMPLEMENTO)), 30) AS COMPL_END,    
     
 CASE B.[TIPOENDERECO]    
  WHEN 'Cobrança'   THEN 32    
  WHEN 'Comercial'  THEN 2    
  WHEN 'Outros'   THEN 7    
  WHEN 'Pager'   THEN 5    
  WHEN 'Pesquisado'  THEN 33    
  WHEN 'Residencial'  THEN 1    
  WHEN 'Pessoal'   THEN 30    
  ELSE 1    
 END AS COD_TIPO,    
    
 CASE     
  WHEN B.CORRESPONDENCIA = 1 THEN 100    
  WHEN B.Ruim = 1 THEN 0    
  ELSE 70    
 END AS PERC_END,    
    
 --IIF(B.Ruim = 1, 1, 0) AS STATUS_END,    
 --IIF(B.PRIORITARIO = 1, 0, 1) AS PRIORIDADE_END, -- 0 = SIM | 1 - NÃO    
      
 'MIGRAÇÃO NEO - LOCALIZA' AS OBS_END,     
 B.DATAINCLUSAO AS DTINCLUSAO_END    
 INTO TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA    
FROM     
 NEO_ESPELHO_ENDERECOS_LOCALIZA AS B WITH(NOLOCK)    
 JOIN SRC.DBO.CAD_UF AS C WITH(NOLOCK) ON B.UF  = C.DESC_UF    
WHERE       
 --LEN(RTRIM(LTRIM(B.ENDERECO))) <= 65 AND    
 --LEN(RTRIM(LTRIM(B.BAIRRO)))   <= 50 AND    
 --LEN(RTRIM(LTRIM(B.CIDADE)))   <= 35 AND    
 --LEN(RTRIM(LTRIM(B.CEP)))   <= 9  AND    
 --LEN(RTRIM(LTRIM(B.NUMERO)))   <= 10 AND    
    
 LEN(RTRIM(LTRIM(B.ENDERECO))) <= 65 AND  LEN(RTRIM(LTRIM(B.BAIRRO)))   <= 30 AND  LEN(RTRIM(LTRIM(B.CIDADE)))   <= 35 AND  LEN(RTRIM(LTRIM(B.CEP)))   <= 8  AND  LEN(RTRIM(LTRIM(B.NUMERO)))   <= 6  AND    
    
 EXISTS (SELECT * FROM SRC.DBO.CAD_DEV AS D WITH(NOLOCK)     
   WHERE B.CPF_DEV = D.CPF_DEV)    
    
 --AND EXISTS (SELECT * FROM AUXSRC.DBO.TBL_CPFS_TESTE_MIGRACAO_LOCALIZA AS Z    
 --    WHERE B.CPF_DEV = Z.CPF_DEV)    
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd    
    
/* ************************************************************** UPDATE ************************************************************** */    
set @dt_ini = getdate()    
IF OBJECT_ID ('TEMPDB.DBO.#TEMP_UPDATE_ENDERECOS_MIGACAO') IS NOT NULL    
BEGIN    
 DROP TABLE #TEMP_UPDATE_ENDERECOS_MIGACAO    
END;    
    
SELECT     
 X.CPF_DEV, Y.COD_END, Y.PERC_END, X.PERC_END AS PERC_END_NEO,    
 ROW_NUMBER() OVER( ORDER BY X.CPF_DEV) AS ID    
 INTO #TEMP_UPDATE_ENDERECOS_MIGACAO    
FROM     
 TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA AS X    
 JOIN SRC.DBO.CAD_DEVE AS Y WITH(NOLOCK) ON Y.CPF_DEV = X.CPF_DEV AND X.CEP_END = Y.CEP_END AND X.RUA_END = Y.RUA_END AND X.NUM_END = Y.NUM_END    
WHERE    
 Y.PERC_END <> X.PERC_END     
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, '#TEMP_UPDATE_ENDERECOS_MIGACAO', @Dt_Ini, @Dt_Fim, @Qtd    
    
-------------------------------------------------------------------    
DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
SET @BLOCO = 1000    
    
if @Qtd > 0    
begin    
 set @dt_ini = getdate()     
    
 SET @VLR_INI = 1    
 SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
 SELECT @VLR_TOT = MAX(ID) FROM #TEMP_UPDATE_ENDERECOS_MIGACAO    
    
 IF @VLR_TOT > 0     
 BEGIN    
  WHILE 1=1    
  BEGIN    
   UPDATE A SET    
    A.PERC_END = B.PERC_END_NEO    
   FROM    
    SRC.DBO.CAD_DEVE AS A    
    JOIN #TEMP_UPDATE_ENDERECOS_MIGACAO AS B ON A.CPF_DEV = B.CPF_DEV AND A.COD_END = B.COD_END    
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
 exec stpLogTempoExecucao @obj, 'UPDATE ENDEREÇO', @Dt_Ini, @Dt_Fim, @Qtd    
end;    
    
/* ************************************************************** INSERT ************************************************************** */    
    
set @dt_ini = getdate()    
IF OBJECT_ID ('TEMPDB.DBO.#TEMP_INSERT_ENDERECOS_MIGACAO') IS NOT NULL    
BEGIN    
 DROP TABLE #TEMP_INSERT_ENDERECOS_MIGACAO    
END;    
    
SELECT     
 CPF_DEV, RUA_END, BAIRRO_END, CIDADE_END, COD_UF, CEP_END, NUM_END, COMPL_END, COD_TIPO, PERC_END, OBS_END, DTINCLUSAO_END,     
 ROW_NUMBER() OVER(PARTITION BY CPF_DEV ORDER BY CPF_DEV)+    
 COALESCE((SELECT MAX(Z.COD_END) FROM SRC.DBO.CAD_DEVE AS Z WITH(NOLOCK)     
     WHERE Z.CPF_DEV = X.CPF_DEV),0)         AS COD_END,    
 ROW_NUMBER() OVER( ORDER BY CPF_DEV) AS ID    
 INTO #TEMP_INSERT_ENDERECOS_MIGACAO    
FROM     
 TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA AS X    
WHERE    
 NOT EXISTS (SELECT * FROM SRC.DBO.CAD_DEVE AS Y WITH(NOLOCK)    
    WHERE Y.CPF_DEV = X.CPF_DEV AND X.CEP_END = Y.CEP_END AND X.RUA_END = Y.RUA_END AND X.NUM_END = Y.NUM_END)    
    
set @Qtd = @@ROWCOUNT    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, '#TEMP_INSERT_ENDERECOS_MIGACAO', @Dt_Ini, @Dt_Fim, @Qtd    
    
set @qtdtot = @Qtd    
    
-------------------------------------------------------------------    
    
if @Qtd > 0    
begin    
    
 --DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
 set @dt_ini = getdate()    
    
 SET @VLR_INI = 1    
 SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
 SELECT @VLR_TOT = MAX(ID) FROM #TEMP_INSERT_ENDERECOS_MIGACAO    
    
 IF @VLR_TOT > 0     
 BEGIN    
  WHILE 1=1    
  BEGIN    
   INSERT SRC.DBO.CAD_DEVE(    
    CPF_DEV, RUA_END, BAIRRO_END, CIDADE_END, COD_UF, CEP_END, NUM_END, COMPL_END, COD_TIPO, PERC_END, OBS_END, DTINCLUSAO_END, COD_END    
   )    
   SELECT CPF_DEV, RUA_END, BAIRRO_END, CIDADE_END, COD_UF, CEP_END, NUM_END, COMPL_END, COD_TIPO, PERC_END, OBS_END, DTINCLUSAO_END, COD_END    
   FROM #TEMP_INSERT_ENDERECOS_MIGACAO AS X    
   WHERE ID BETWEEN @VLR_INI AND @VLR_FIN    
    
   INSERT SRC.DBO.AUX_DEVE( CPF_DEV, COD_END, COD_RECUP_INC_ALTER )    
   SELECT CPF_DEV, COD_END, 377 FROM #TEMP_INSERT_ENDERECOS_MIGACAO AS X WHERE ID BETWEEN @VLR_INI AND @VLR_FIN    
    
   IF @VLR_FIN >= @VLR_TOT    
   BEGIN    
    BREAK    
   END    
    
   SET @VLR_INI += @BLOCO    
   SET @VLR_FIN += @BLOCO    
  END    
 END;    
    
 set @dt_fim = getdate()    
 exec stpLogTempoExecucao @obj, 'INSERT ENDEREÇO', @Dt_Ini, @Dt_Fim, @Qtd    
end;    
    
/* ************************************************************** AUX_DEVE ************************************************************** */    
/*    
IF OBJECT_ID ('tempdb.dbo.#TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVE') IS NOT NULL    
BEGIN    
 DROP TABLE #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVE    
END;    
    
SELECT     
 Y.CPF_DEV, Y.COD_END, ROW_NUMBER() OVER(ORDER BY CPF_DEV) AS ID    
 INTO #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVE    
FROM     
 TBL_TEMP_MIGRACAO_ENDERECO_NEO_LOCALIZA AS X WITH(NOLOCK)    
 JOIN SRC.DBO.CAD_DEVE AS Y WITH(NOLOCK) ON Y.CPF_DEV = X.CPF_DEV AND X.CEP_END = Y.CEP_END AND X.RUA_END = Y.RUA_END AND X.NUM_END = Y.NUM_END    
WHERE    
 NOT EXISTS (SELECT * FROM SRC.DBO.AUX_DEVE AS Z WITH(NOLOCK)     
    WHERE Y.CPF_DEV = Z.CPF_DEV AND Y.COD_END = Z.COD_END)    
    
-------------------------------------------------------------------    
    
DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
    
SET @BLOCO = 1000    
    
SET @VLR_INI = 1    
SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
SELECT @VLR_TOT = MAX(ID) FROM #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVE    
    
IF @VLR_TOT > 0     
BEGIN    
 WHILE 1=1    
 BEGIN    
  INSERT SRC.DBO.AUX_DEVE ( CPF_DEV, COD_END, COD_RECUP_INC_ALTER )    
  SELECT CPF_DEV, COD_END, 377 FROM #TEMP_INSERT_TELEFONES_MIGACAO_AUX_DEVE AS X WHERE ID BETWEEN @VLR_INI AND @VLR_FIN    
    
  IF @VLR_FIN >= @VLR_TOT    
  BEGIN    
   BREAK    
  END    
    
  SET @VLR_INI += @BLOCO    
  SET @VLR_FIN += @BLOCO    
 END    
END;    
*/    
    
    
end try    
begin catch    
 EXEC STP_LOG_ERRO 'stpMigracaoEnderecoLocaliza'    
    
 SELECT      
    ERROR_NUMBER() AS ERRORNUMBER        
   ,ERROR_SEVERITY() AS ERRORSEVERITY        
   ,ERROR_STATE() AS ERRORSTATE        
   ,ERROR_PROCEDURE() AS ERRORPROCEDURE        
   ,ERROR_LINE() AS ERRORLINE        
   ,ERROR_MESSAGE() AS ERRORMESSAGE;      
end catch