
CREATE PROC StpLogTempoExecucao (  
 @Objeto varchar(max), @Etapa varchar(max), @Dt_Ini datetime, @Dt_Fim datetime, @Qtd int  
)  
AS  
BEGIN TRY  
  
 IF OBJECT_ID ('TBL_LOGTEMPOEXECUCAO') IS NULL  
 BEGIN  
        CREATE TABLE TBL_LOGTEMPOEXECUCAO(  
   ID INT IDENTITY (1,1) PRIMARY KEY,  
   OBJETO VARCHAR(MAX),  
   ETAPA VARCHAR(MAX),  
   DT_INI DATETIME,  
   DT_FIM DATETIME,  
   QTD INT  
        )  
    END  
  
    INSERT INTO TBL_LOGTEMPOEXECUCAO (OBJETO, ETAPA, DT_INI, DT_FIM, QTD)  
    VALUES (@OBJETO, @ETAPA, @DT_INI, @DT_FIM, @QTD)  
  
END TRY  
BEGIN CATCH  
    EXEC STP_LOG_ERRO 'StpLogTempoExecucao'  
END CATCH  
  