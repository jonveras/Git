      
CREATE PROCEDURE stpMigracaoEmailLocaliza(      
 @qtdtot int = 0 output       
)      
as      
BEGIN TRY      
      
DECLARE @OBJ VARCHAR(100) = 'stpMigracaoEmailLocaliza'      
DECLARE @DT_INI DATETIME, @DT_FIM DATETIME, @QTD INT = NULL      
      
-----------------------------------------------------------      
      
set @dt_ini = getdate()      
IF OBJECT_ID ('TBL_TEMP_MIGRACAO_EMAIL_NEO_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE TBL_TEMP_MIGRACAO_EMAIL_NEO_LOCALIZA      
END;      
      
SELECT       
 B.CPF_DEV,      
 B.DESCRICAO AS DESC_DEVMAIL,      
      
 CASE B.[TIPO]      
  WHEN 'Celular'   THEN 4      
  WHEN 'Celular Extra' THEN 4      
  WHEN 'Comercial'  THEN 2      
  WHEN 'Fax'    THEN 5      
  WHEN 'Outros'   THEN 7      
  WHEN 'Pager'   THEN 5      
  WHEN 'Pesquisado'  THEN 33      
  WHEN 'Residencial'  THEN 1      
  WHEN 'Pessoal'   THEN 30      
  ELSE 1      
 END AS COD_TIPO,      
 CASE       
  WHEN B.LISTANEGRA = 1 THEN 0      
  WHEN B.PRIORITARIO = 1 THEN 100      
  WHEN B.[STATUS] = 'Excluído' THEN 0      
  WHEN B.[STATUS] = 'ExcluÝdo' THEN 0      
  WHEN B.[STATUS] = 'Ruim' THEN 10      
  WHEN B.[STATUS] = 'Pesq.' THEN 40      
  WHEN B.[STATUS] = 'Novo' THEN 50      
  WHEN B.[STATUS] = 'Bom' THEN 70      
  ELSE 50      
 END AS PERC_MAIL,      
 CASE      
  WHEN B.LISTANEGRA = 1 THEN 1      
  WHEN B.[STATUS] = 'Excluído' THEN 1      
  WHEN B.[STATUS] = 'ExcluÝdo' THEN 1      
  ELSE 0      
 END AS STATUS_MAIL, -- 0 = ATIVO | 1 - INATIVO      
      
 --IIF(B.PRIORITARIO = 1, 0, 1) AS PRIORIDADE_TEL, -- 0 = SIM | 1 - NÃO          
 IIF(COALESCE(B.OBS,'') <> '', 'MIGRAÇÃO NEO - LOCALIZA | OBS: ' + B.OBS , 'MIGRAÇÃO NEO - LOCALIZA') AS OBS_MAIL,      
       
 B.DATAINCLUSAO AS DTINCLUSAO_DEVMAIL      
 INTO TBL_TEMP_MIGRACAO_EMAIL_NEO_LOCALIZA      
FROM       
 NEO_ESPELHO_EMAIL_LOCALIZA AS B WITH(NOLOCK)      
WHERE       
 EXISTS (SELECT * FROM SRC.DBO.CAD_DEV AS C WITH(NOLOCK)       
   WHERE B.CPF_DEV = C.CPF_DEV)      
 AND LEN(DESCRICAO) < 50    
      
set @Qtd = @@ROWCOUNT      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'TBL_TEMP_MIGRACAO_EMAIL_NEO_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
set @qtdtot = @Qtd      
      
/* ************************************************************** UPDATE ************************************************************** */      
      
set @dt_ini = getdate()      
IF OBJECT_ID ('TEMPDB.DBO.#TEMP_UPDATE_EMAILS_MIGACAO') IS NOT NULL      
BEGIN      
 DROP TABLE #TEMP_UPDATE_EMAILS_MIGACAO      
END;      
      
SELECT       
 X.CPF_DEV, Y.COD_DEVMAIL, Y.PERC_MAIL, X.PERC_MAIL AS PERC_MAIL_NEO, X.STATUS_MAIL,      
 ROW_NUMBER() OVER( ORDER BY X.CPF_DEV) AS ID      
 INTO #TEMP_UPDATE_EMAILS_MIGACAO      
FROM       
 TBL_TEMP_MIGRACAO_EMAIL_NEO_LOCALIZA AS X      
 JOIN SRC.DBO.CAD_DEVMAIL AS Y WITH(NOLOCK) ON Y.CPF_DEV = X.CPF_DEV AND X.DESC_DEVMAIL = Y.DESC_DEVMAIL      
WHERE      
 Y.PERC_MAIL <> X.PERC_MAIL       
      
set @Qtd = @@ROWCOUNT      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, '#TEMP_UPDATE_EMAILS_MIGACAO', @Dt_Ini, @Dt_Fim, @Qtd      
      
--select * into tbl_log_UPDATE_EMAILS_MIGACAO      
--from #TEMP_UPDATE_EMAILS_MIGACAO      
      
-------------------------------------------------------------------      
DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT      
SET @BLOCO = 5000      
      
if @Qtd > 0      
begin      
 set @dt_ini = getdate()       
      
 SET @VLR_INI = 1      
 SET @VLR_FIN = (@VLR_INI + @BLOCO)-1      
 SELECT @VLR_TOT = MAX(ID) FROM #TEMP_UPDATE_EMAILS_MIGACAO      
      
 IF @VLR_TOT > 0       
 BEGIN      
  WHILE 1=1      
  BEGIN      
   UPDATE A SET      
    A.PERC_MAIL = B.PERC_MAIL_NEO      
   FROM      
    SRC.DBO.CAD_DEVMAIL AS A      
    JOIN #TEMP_UPDATE_EMAILS_MIGACAO AS B ON A.CPF_DEV = B.CPF_DEV AND A.COD_DEVMAIL = B.COD_DEVMAIL      
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
 exec stpLogTempoExecucao @obj, 'UPDATE PERC EMAILS', @Dt_Ini, @Dt_Fim, @Qtd      
end;      
      
      
/* ************************************************************** INSERT ************************************************************** */      
      
set @dt_ini = getdate()      
IF OBJECT_ID ('TEMPDB.DBO.#TEMP_INSERT_EMAILS_MIGACAO') IS NOT NULL      
BEGIN      
 DROP TABLE #TEMP_INSERT_EMAILS_MIGACAO      
END;      
      
SELECT *,      
 ROW_NUMBER() OVER(PARTITION BY X.CPF_DEV ORDER BY CPF_DEV)+      
 COALESCE((SELECT MAX(Z.COD_DEVMAIL) FROM SRC.DBO.CAD_DEVMAIL AS Z WITH(NOLOCK)       
     WHERE Z.CPF_DEV = X.CPF_DEV),0)         AS COD_DEVMAIL,      
 ROW_NUMBER() OVER( ORDER BY CPF_DEV) AS ID      
 INTO #TEMP_INSERT_EMAILS_MIGACAO      
FROM       
 TBL_TEMP_MIGRACAO_EMAIL_NEO_LOCALIZA AS X      
WHERE      
 NOT EXISTS (SELECT * FROM SRC.DBO.CAD_DEVMAIL AS Y WITH(NOLOCK)      
    WHERE Y.CPF_DEV = X.CPF_DEV AND X.DESC_DEVMAIL = Y.DESC_DEVMAIL)      
      
set @Qtd = @@ROWCOUNT      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, '#TEMP_INSERT_EMAILS_MIGACAO', @Dt_Ini, @Dt_Fim, @Qtd      
      
-------------------------------------------------------------------      
if @Qtd > 0      
begin      
      
 --DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT      
 set @dt_ini = getdate()      
      
 SET @VLR_INI = 1      
 SET @VLR_FIN = (@VLR_INI + @BLOCO)-1      
 SELECT @VLR_TOT = MAX(ID) FROM #TEMP_INSERT_EMAILS_MIGACAO      
      
 WHILE 1=1      
 BEGIN      
  INSERT SRC.DBO.CAD_DEVMAIL(      
   CPF_DEV, DESC_DEVMAIL, COD_TIPO, PERC_MAIL, STATUS_MAIL, OBS_MAIL, DTINCLUSAO_DEVMAIL, COD_DEVMAIL      
  )      
  SELECT      
   CPF_DEV, DESC_DEVMAIL, COD_TIPO, PERC_MAIL, STATUS_MAIL, OBS_MAIL, DTINCLUSAO_DEVMAIL, COD_DEVMAIL      
  FROM #TEMP_INSERT_EMAILS_MIGACAO      
  WHERE ID BETWEEN @VLR_INI AND @VLR_FIN      
      
  INSERT SRC.DBO.AUX_DEVMAIL( CPF_DEV, COD_DEVMAIL, COD_RECUP_INC_ALTER )      
  SELECT CPF_DEV, COD_DEVMAIL, 377 FROM #TEMP_INSERT_EMAILS_MIGACAO       
  WHERE ID BETWEEN @VLR_INI AND @VLR_FIN      
      
  IF @VLR_FIN >= @VLR_TOT      
  BEGIN      
   BREAK      
  END      
      
  SET @VLR_INI += @BLOCO      
  SET @VLR_FIN += @BLOCO      
 END;      
      
 set @dt_fim = getdate()      
 exec stpLogTempoExecucao @obj, 'INSERT EMAIL', @Dt_Ini, @Dt_Fim, @Qtd      
end;      
      
/* **************************************************** BLACKLIST **************************************************** */      
      
set @dt_ini = getdate()      
INSERT SRC.DBO.CAD_BLACKLIST_EMAIL (      
 CPF_DEV, EMAIL, DATA_INCLUSAO      
)      
SELECT *      
FROM (      
 SELECT       
  CPF_DEV,      
  DESCRICAO AS EMAIL,      
  GETDATE() AS DATA_INCLUSAO      
 FROM       
  NEO_ESPELHO_EMAIL_LOCALIZA as b WITH(NOLOCK)      
 WHERE       
  LISTANEGRA = 1      
 --AND EXISTS (SELECT * FROM AUXSRC.DBO.TBL_CPFS_TESTE_MIGRACAO_LOCALIZA AS Z      
 --     WHERE B.CPF_DEV = Z.CPF_DEV)      
) AS X      
WHERE      
 NOT EXISTS (SELECT * FROM SRC.DBO.CAD_BLACKLIST_EMAIL AS Y WITH(NOLOCK)      
    WHERE Y.CPF_DEV = X.CPF_DEV AND X.EMAIL = Y.EMAIL)      
      
set @Qtd = @@ROWCOUNT      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'BLACKLIST EMAIL', @Dt_Ini, @Dt_Fim, @Qtd      
      
end try      
begin catch      
 EXEC STP_LOG_ERRO 'stpMigracaoEmailLocaliza'      
      
 SELECT        
    ERROR_NUMBER() AS ERRORNUMBER          
   ,ERROR_SEVERITY() AS ERRORSEVERITY          
   ,ERROR_STATE() AS ERRORSTATE          
   ,ERROR_PROCEDURE() AS ERRORPROCEDURE          
   ,ERROR_LINE() AS ERRORLINE          
   ,ERROR_MESSAGE() AS ERRORMESSAGE;        
end catch