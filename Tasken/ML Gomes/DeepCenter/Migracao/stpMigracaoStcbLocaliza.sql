    
CREATE PROCEDURE stpMigracaoStcbLocaliza(    
 @qtdtot int = 0 output    
)    
as    
BEGIN TRY    
    
DECLARE @OBJ VARCHAR(100) = 'stpMigracaoStcbLocaliza'    
DECLARE @DT_INI DATETIME, @DT_FIM DATETIME, @QTD INT = NULL    
    
-----------------------------------------------------------------------------------------------------------------    
    
set @dt_ini = getdate()    
IF OBJECT_ID('TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA') IS NOT NULL    
BEGIN    
 DROP TABLE TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA;    
END;    
    
--SELECT COUNT (*) FROM TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA_OLD    
--SELECT COUNT (*) FROM TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA    
    
SELECT     
 * INTO TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA    
FROM (    
 SELECT    
  C.CONTRATO_FIN, B.CONTRATO_ORIGINAL, C.COD_STCB, D.DESCRICAOAGENDAMENTO, D.DATAHORAMUDANCA, D.PESO, E.COD_STCB AS COD_STCB_NEO,    
  ROW_NUMBER() OVER(ORDER BY A.IDCONTRATO) AS ID    
 FROM     
  AUXSRC.DBO.NEO_ESPELHO_CONTRATOS_LOCALIZA     AS A WITH(NOLOCK)    
  JOIN AUXSRC.DBO.TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS B WITH(NOLOCK) ON A.IDCONTRATO = B.IDCONTRATO    
  JOIN SRC.DBO.CAD_DEVF          AS C WITH(NOLOCK) ON B.CONTRATO_FIN = C.CONTRATO_FIN    
  CROSS APPLY ( SELECT TOP 1 D.DESCRICAOAGENDAMENTO, D.DATAHORAMUDANCA, D2.PESO    
       FROM AUXSRC.DBO.NEO_ESPELHO_HISTORICO_STCB_LOCALIZA AS D WITH(NOLOCK)    
       JOIN AUXSRC.[DBO].[PESO_STCB_NEO] AS D2 ON D.[DESCRICAOAGENDAMENTO] = D2.[DESCRIÇÃO]    
       WHERE D.IDCONTRATO = A.IDCONTRATO     
       AND D.DATAHORAMUDANCA >= A.DATARECEBIMENTOCONTRATO    
       ORDER BY D2.PESO DESC, D.DATAHORAMUDANCA DESC   ) AS D    
      
  JOIN AUXSRC.DBO.TBL_MIGRACAO_DEPARA_STATUSCOBRANCA_LOCALIZA AS E WITH(NOLOCK) ON E.FILA_COBRANCA = D.DESCRICAOAGENDAMENTO    
 --WHERE    
 -- A.STATUSCONTRATO NOT IN ('Devolvido','Liquidado')    
 --where exists (select * from auxsrc.dbo.TBL_CPFS_TESTE_MIGRACAO as xxx with(nolock) where xxx.contrato_fin = b.CONTRATO_FIN)    
) AS X    
WHERE     
 COD_STCB_NEO <> COD_STCB    
    
set @qtd = @@rowcount    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd    
    
set @qtdtot = @QTD    
    
--SELECT *     
--FROM TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA WITH(NOLOCK)    
--WHERE COD_STCB_NEO <> COD_STCB    
-----------------------------------------------------------------------------------------------------------------    
    
set @dt_ini = getdate()    
DECLARE @VLR_INI INT, @VLR_FIN INT, @VLR_TOT INT, @BLOCO INT    
    
SET @BLOCO = 1000    
SET @VLR_INI = 1    
SET @VLR_FIN = (@VLR_INI + @BLOCO)-1    
SELECT @VLR_TOT = MAX(ID) FROM TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA WITH(NOLOCK)    
    
IF @VLR_TOT > 0    
BEGIN    
 WHILE 1=1    
 BEGIN    
     
  UPDATE A SET    
   A.COD_STCB = B.COD_STCB_NEO,    
   A.COD_STCBANT = B.COD_STCB    
  FROM SRC.DBO.CAD_dEVF AS A    
  JOIN AUXSRC.DBO.TBL_AJUSTE_STCB_MIGRACAO_NEO_LOCALIZA AS B ON A.CONTRATO_FIN = B.CONTRATO_FIN    
  WHERE B.ID BETWEEN @VLR_INI AND @VLR_FIN    
    
  IF @VLR_FIN >= @VLR_TOT    
  BEGIN    
   BREAK;    
  END;    
    
  SET @VLR_INI += @BLOCO    
  SET @VLR_FIN += @BLOCO    
 END;    
END;    
    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'UPDATE STCB', @Dt_Ini, @Dt_Fim, @Qtd    
    
end try    
begin catch    
 EXEC STP_LOG_ERRO 'stpMigracaoStcbLocaliza'    
    
 SELECT      
    ERROR_NUMBER() AS ERRORNUMBER        
   ,ERROR_SEVERITY() AS ERRORSEVERITY        
   ,ERROR_STATE() AS ERRORSTATE        
   ,ERROR_PROCEDURE() AS ERRORPROCEDURE        
   ,ERROR_LINE() AS ERRORLINE        
   ,ERROR_MESSAGE() AS ERRORMESSAGE;      
end catch