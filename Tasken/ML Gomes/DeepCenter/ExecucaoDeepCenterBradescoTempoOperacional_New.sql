USE [SRC]
GO

/****** Object:  StoredProcedure [dbo].[ExecucaoDeepCenterBradescoTempoOperacional_New]    Script Date: 07/05/2025 13:46:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ExecucaoDeepCenterBradescoTempoOperacional_New](
 @DATA DATETIME = NULL, @reprocessar bit = 0              
)              
AS              
/* *************************************************************************************************** *              
 * NOME DO OBJETO : ExecucaoDeepCenterBradescoTempoOperacional             *              
 * CRIA플O: 04/03/202                       *              
 * PROFISSIONAL: LUCAS LIMA                         *              
 * PROJETO: DEEPCENTER                       *               
 * *************************************************************************************************** */              
              
BEGIN TRY              
              
 /* ********************* CRIA A TABELA CASO N홒 EXISTA ********************* */              
 IF OBJECT_ID('SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_TEMPO_OPERACIONAL_FINAL') IS NULL              
 BEGIN              
  CREATE TABLE SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_TEMPO_OPERACIONAL_FINAL              
  (              
    IDUNICO BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY              
   ,DATA DATETIME              
   ,DATAINSERT DATETIME DEFAULT GETDATE()              
   ,INICIOEVENTO DATETIME              
   ,TERMINOEVENTO DATETIME              
   ,AGENTE VARCHAR(50)              
   ,IDAGENT VARCHAR(50)              
   ,EVENTO INT              
  )              
 END              
              
 /* ********************* DROPANDO TABELAS SELE플O ********************* */              
 IF OBJECT_ID('SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO              
 END              
              
 IF OBJECT_ID('SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO              
 END              
              
 IF OBJECT_ID('SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO              
 END              
              
 IF OBJECT_ID ('SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO              
 END              
               
 /* ********************* SELECIONANDO DATA EXPORTA플O ********************* */              
 DECLARE @DATA2 DATETIME = NULL              
              
 IF @DATA IS NULL              
 BEGIN              
  SET @DATA  = CAST(GETDATE() AS DATE)              
 END              
              
 SET @DATA2 = CONVERT(VARCHAR(10), @DATA, 120) + ' 23:59:59'              
              
 IF @REPROCESSAR = 1              
 BEGIN              
  DELETE FROM SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_TEMPO_OPERACIONAL_FINAL              
  WHERE [DATA] = @DATA              
 END;              
              
 /* ********************* SELE플O CAD_ATENDIMENTO ********************* */              
 IF OBJECT_ID('SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO') IS NULL              
 BEGIN              
  SELECT               
   A.COD_RECUP,       
   A.HORA_INI, A.HORA_FIM,E.PRODPORTFOLIODEEPCENTER_CAR AS PORTFOLIO      
   ,B.COD_CLI, J.FILLER, C.COD_EMPRESA, R.CPF_DEV, D.COD_TIPESS,
   J.FILA_COBRANCA AS JFILA_COBRANCA, C.FILA_COBRANCA AS BFILA_COBRANCA, L.FILA_COBRANCA AS CFILA_COBRANCA
   INTO SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO              
  FROM               
   [SRC].dbo.CAD_ATENDIMENTO A (NOLOCK)              
   JOIN [SRC].dbo.CAD_DEVF B (NOLOCK) ON A.CONTRATO_FIN = B.CONTRATO_FIN AND B.COD_CLI IN (3,11,16,17)            
   JOIN [SRC].dbo.CAD_CAR_AUX_AUX E (NOLOCK) ON B.COD_CLI = E.COD_CLI AND B.COD_CAR = E.COD_CAR            
   JOIN [SRC].DBO.CAD_DEV AS D WITH(NOLOCK) ON B.CPF_DEV = D.CPF_DEV         
   LEFT JOIN TBL_BRADESCO_PORTOLIO_35 AS R WITH (NOLOCK) ON R.CPF_DEV = A.CPF_DEV     

   OUTER APPLY (SELECT TOP 1 FILLER, FILA_COBRANCA		  FROM AUX_CARTOESBRADESCO		    AS J WITH(NOLOCK) WHERE J.CONTRATO_FIN = A.CONTRATO_FIN) AS J          
   OUTER APPLY (SELECT TOP 1 COD_EMPRESA, [FILA_COBRANCA] FROM [SRC].dbo.AUX_BRADESCOBANCO  AS C WITH(NOLOCK) WHERE A.CONTRATO_FIN = C.CONTRATO_FIN) AS C          
   OUTER APPLY (SELECT TOP 1 [FILA_COBRANCA]			  FROM SRC.dbo.AUX_BRADESCOLPTITULO AS L WITH(NOLOCK) WHERE L.CONTRATO_FIN = B.CONTRATO_FIN) AS L
  WHERE              
   A.[DATA] BETWEEN @DATA AND @DATA2 AND              
   --EXISTS (SELECT * FROM [SRC].DeepCenter.CAD_DEVF AS C (NOLOCK) WHERE A.CONTRATO_FIN = C.CONTRATO_FIN AND C.COD_CLI IN (3,11) ) AND              
   NOT EXISTS (SELECT * FROM SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_TEMPO_OPERACIONAL_FINAL AS D WHERE A.COD_RECUP = D.IDAGENT AND D.DATA = @DATA)              
              
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO (COD_RECUP) INCLUDE (HORA_INI, HORA_FIM)              
 END      
              
 /* ********************* LOGIN E LOGOUT ********************* */              
 IF OBJECT_ID('SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO') IS NULL              
 BEGIN              
  SELECT *              
   INTO SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO              
  FROM              
   (              
    SELECT 
		A.COD_RECUP,  MIN(A.HORA_INI) AS INICIOEVENTO, NULL AS TERMINOEVENTO, 1 AS EVENTO, PORTFOLIO      
		,COD_CLI, FILLER, COD_EMPRESA, CPF_DEV, COD_TIPESS, CFILA_COBRANCA, BFILA_COBRANCA, JFILA_COBRANCA      
    FROM SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO AS A 
	GROUP BY A.COD_RECUP, PORTFOLIO, COD_CLI, FILLER, COD_EMPRESA, CPF_DEV, COD_TIPESS, CFILA_COBRANCA, BFILA_COBRANCA, JFILA_COBRANCA
    UNION ALL              
    SELECT 
		A.COD_RECUP,  MAX(A.HORA_FIM) AS INICIOEVENTO, NULL AS TERMINOEVENTO, 2 AS EVENTO, PORTFOLIO      
		,COD_CLI, FILLER, COD_EMPRESA, CPF_DEV, COD_TIPESS, CFILA_COBRANCA, BFILA_COBRANCA, JFILA_COBRANCA      
    FROM SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO AS A 
	GROUP BY A.COD_RECUP, PORTFOLIO, COD_CLI, FILLER, COD_EMPRESA, CPF_DEV, COD_TIPESS, CFILA_COBRANCA, BFILA_COBRANCA, JFILA_COBRANCA      
   )              
   AS X              
              
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO (COD_RECUP)              
  INCLUDE (INICIOEVENTO, TERMINOEVENTO, EVENTO)              
 END              
              
 /* ********************* SELE플O TBL_SOLICITAPAUSA ********************* */              
 IF OBJECT_ID('SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO') IS NULL              
 BEGIN              
  SELECT DISTINCT A.COD_RECUP, A.INICIO_PAUSA AS INICIOEVENTO, COALESCE(A.FIM_PAUSA, DATEADD(MI,1,A.INICIO_PAUSA)) AS TERMINOEVENTO, COALESCE(B.COD_EXPORT_DEEP, 10) AS EVENTO,       
  PORTFOLIO AS PORTFOLIO -- 10 - Pausa Outros      
  ,COD_CLI, FILLER, COD_EMPRESA, CPF_DEV, COD_TIPESS, CFILA_COBRANCA, BFILA_COBRANCA, JFILA_COBRANCA      
   INTO SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO              
  FROM               
   [SRC].dbo.TBL_SOLICITAPAUSA AS A (NOLOCK)              
   JOIN [SRC].dbo.CAD_PAUSA AS B (NOLOCK) ON A.COD_PAUSA = B.COD_PAUSA              
   JOIN SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO C ON A.COD_RECUP = C.COD_RECUP          
  WHERE               
   CAST(A.DATA_PAUSA AS DATE) = @DATA               
   --EXISTS (SELECT * FROM SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO AS C WHERE A.COD_RECUP = C.COD_RECUP)               
                
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO (COD_RECUP) INCLUDE (INICIOEVENTO, TERMINOEVENTO, EVENTO)              
 END              
              
 /* ********************* AMARRA합ES ********************* */               
 IF OBJECT_ID('SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO') IS NULL              
 BEGIN              
  SELECT               
  'MLGomes' AS NOMEASSESSORIA,            
   A.COD_RECUP AS IDAGENT,               
   A.NOME_RECUP AS AGENTE,               
   CAST(@DATA AS DATE) AS [DATA],    
   A.USADEEPCENTEROPERACIONAL_RECUP,              
   B.INICIOEVENTO,              
   B.TERMINOEVENTO,              
   B.EVENTO,            
   3 AS SEGMENTO,   
   
     -- OS 171731
	 /*
   CASE          
  WHEN PORTFOLIO <> -1         THEN PORTFOLIO          
  WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '3A52' THEN 39                        
  WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '2A52' THEN 40                        
  --WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '4A53' THEN 41                        
  WHEN COD_CLI = 11 AND COALESCE(COD_TIPESS,0) = 0 AND SUBSTRING(ltrim(FILLER), 3, 3) = 'A53'  THEN 1019 -- OS170702                          
  WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '7A51' THEN 42                          
  WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '8A51' THEN 43                        
  WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '6A51' THEN 52 -- OS167390                        
  WHEN COD_CLI = 11 AND SUBSTRING(FILLER, 3, 5) = '1A52' THEN 53 -- OS167390                        
  WHEN COD_CLI = 11          THEN 44                        
  WHEN COD_EMPRESA = 'ABLG0000'       THEN 1                        
  WHEN CPF_DEV IS NOT NULL        THEN 1 -- OS168675                                        
 ELSE PORTFOLIO      
   END AS PORTFOLIO      
   */

  -- OS 171731
  CASE                               
   WHEN B.COD_CLI = 11		 THEN (SELECT top 1 PTF.COD_PORTFOLIO FROM DEEPCENTER.CAD_PORTFOLIO AS PTF WHERE PTF.FILA_COBRANCA = B.JFILA_COBRANCA)
   WHEN B.COD_CLI IN (16,17) THEN (SELECT top 1 PTF.COD_PORTFOLIO FROM DEEPCENTER.CAD_PORTFOLIO AS PTF WHERE PTF.FILA_COBRANCA = B.CFILA_COBRANCA)
   ELSE							  (SELECT top 1 PTF.COD_PORTFOLIO FROM DEEPCENTER.CAD_PORTFOLIO AS PTF WHERE PTF.FILA_COBRANCA = B.BFILA_COBRANCA)
  END AS PORTFOLIO

   INTO SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO              
  FROM              
   [SRC].dbo.CAD_RECUP AS A              
   CROSS APPLY (               
       SELECT * FROM SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO AS C              
       WHERE C.COD_RECUP = A.COD_RECUP              
              UNION ALL              
       SELECT * FROM SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO AS D              
       WHERE D.COD_RECUP = A.COD_RECUP               
       )               
      AS B              
  WHERE              
   --A.USADEEPCENTEROPERACIONAL_RECUP = 0 AND       
   B.INICIOEVENTO IS NOT NULL    


 END              
          
  -- OS 171731
 --UPDATE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO SET PORTFOLIO = 1006 WHERE PORTFOLIO = 43;          
 --UPDATE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO SET PORTFOLIO = 1007 WHERE PORTFOLIO = 1;          
 --UPDATE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO SET PORTFOLIO = 1023 WHERE PORTFOLIO = 2;          
 --UPDATE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO SET PORTFOLIO = 1025 WHERE PORTFOLIO = 42;          
 --UPDATE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO SET PORTFOLIO = 1032 WHERE PORTFOLIO = 52;          
 --UPDATE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO SET PORTFOLIO = 1036 WHERE PORTFOLIO = 44;          
          
 /* ********************* DEEPCENTER_TEMPO OPERACIONAL ********************* */               
 WHILE 1=1              
 BEGIN              
  DELETE TOP (1000)               
   SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO              
  OUTPUT              
   -- DELETED.[DATA]              
   --,DELETED.INICIOEVENTO               
   --,DELETED.TERMINOEVENTO               
   --,DELETED.AGENTE               
   --,DELETED.IDAGENT               
   --,DELETED.EVENTO              
            
   DELETED.NOMEASSESSORIA            
   ,DELETED.[DATA]              
   ,DELETED.INICIOEVENTO               
   ,COALESCE(DELETED.TERMINOEVENTO,DELETED.INICIOEVENTO)               
  ,DELETED.AGENTE               
   ,DELETED.IDAGENT               
   ,DELETED.EVENTO              
   ,DELETED.SEGMENTO            
   ,COALESCE(DELETED.PORTFOLIO,0)          
              
  INTO SRC.[DeepCenter].[FINAL_TEMPOOPERACIONAL]  
  (              
 DSNOMEASSESSORIA            
   ,DTDATAREFERENCIA              
   ,HRHORAINICIO               
   ,HRHORAFIM               
   ,DSNOMEAGENT               
   ,DSIDAGENT               
   ,IDEVENTO              
   ,DSSEGMENTO            
   ,DSPORTFOLIO            
  )              
  FROM              
   SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO              
              
  IF @@ROWCOUNT < 1000 BREAK              
 END               
              
 /* ********************* DROPANDO TABELAS SELE플O ********************* */               
 IF OBJECT_ID('SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.CAD_ATENDIMENTO_SELECAO_TEMPO_OPERACIONAL_BRADESCO              
 END              
              
 IF OBJECT_ID('SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.CAD_ATENDIMENTO_LOGIN_LOGOUT_TEMPO_OPERACIONAL_BRADESCO              
 END              
              
 IF OBJECT_ID('SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.TBL_SOLICITAPAUSA_SELECAO_TEMPO_OPERACIONAL_BRADESCO        
 END              
              
 IF OBJECT_ID ('SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO') IS NOT NULL              
 BEGIN              
  DROP TABLE SRC.DeepCenter.TBL_TEMPO_OPERACIONAL_FINAL_BRADESCO              
 END              
              
END TRY              
BEGIN CATCH              
 EXEC STP_LOG_ERRO 'ExecucaoDeepCenterBradescoTempoOperacional'              
END CATCH 
GO


