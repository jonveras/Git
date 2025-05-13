USE [SRC]
GO

/****** Object:  StoredProcedure [dbo].[ExecucaoDeepCenterlBradescoComercialMulticanal_NEW]    Script Date: 07/05/2025 13:48:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ExecucaoDeepCenterlBradescoComercialMulticanal_NEW](                                            
 @DATA DATETIME = NULL, @Reprocessar bit = 0                                            
)                                     
WITH RECOMPILE                        
AS                                            
/* *********************************************************************************************** *                                            
 * NOME DO OBJETO : ExecucaoRedeBrasilBradescoMulticanal             *                                            
 * CRIA플O: 12/09/2019                      *                                            
 * PROFISSIONAL: LUCAS LIMA                     *                                            
 * PROJETO: DEEPCENTER                      *                                             
 * *********************************************************************************************** */                                            
                                            
BEGIN TRY                                            
                                            
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                                            
                                            
 DECLARE @VLR_INI INT = 1, @VLR_FIN INT = 1000, @BLOCO INT = 1000, @ID_LOG INT = 0, @QTD INT = 0, @QTD_SMS INT = 0                                            
                                            
 EXEC stpGravaLogDeepCenter 0, 'COMERCIAL-CARTAO', 'MULTICANAL', @ID_LOG OUTPUT                                     
                                            
    /******************* TABELA DE CONTROLE *******************/                                             
 IF OBJECT_ID('SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL') IS NULL                                            
 BEGIN                                            
  CREATE TABLE SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL (                                            
    IDUNICO     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY                                            
   ,DATAINSERT    DATETIME DEFAULT GETDATE()                                               
   ,ID_ACIONA           INT                                  
   ,ID_SMS  INT NULL                                  
  )                                            
  CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL(ID_ACIONA) INCLUDE (IDUNICO, DATAINSERT)                                            
 END                                            
                                            
 /******************* TABELA FINAL DEEPCENTER *******************/                                            
 IF OBJECT_ID('SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_MULTICANAL_FINAL') IS NULL                                            
 BEGIN                                            
  CREATE TABLE SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_MULTICANAL_FINAL                                            
  (                                               
    IDUNICO     BIGINT  IDENTITY(1,1) PRIMARY KEY                                          
   ,DATAINSERT    DATETIME                                            
   ,DATA      DATE                                            
   ,HORA      TIME                                            
   ,IDCUSTOMER       VARCHAR(500)                                            
   ,CPF      VARCHAR(500)                                            
   ,CNPJ      VARCHAR(500)                                            
   ,CONTRATO     VARCHAR(500)                                            
   ,SEGMENTOCANAL    INT                                            
   ,PORTFOLIO     INT                                            
   ,PRODUTOPORTFOLIO   INT                                            
   ,CARTEIRA     VARCHAR(500)                                            
   ,PRODUTO     VARCHAR(500)              
   ,SUBPRODUTO    VARCHAR(500)                                            
   ,TIPOCANAL    INT                                            
   ,PHONENUMBER    VARCHAR(500)                    
   ,FORNECEDOR    VARCHAR(500)                                            
   ,[EMAIL INEXISTENTE] INT                                            
   ,ENTREGA     INT                                            
   ,EMAIL   VARCHAR(500)                                            
   ,RESPOSTA     INT                                            
   ,NAVEGADOR     VARCHAR(500)                                            
   ,ABERTO     INT                                            
   ,LIDO INT                                            
   ,VLRPRINC     FLOAT                                            
   ,VLRATRASO     FLOAT                       
   ,PARCELAATRASO    INT                                            
   ,OPTIAGENDA    BIT                                            
   ,DATAACORDO    DATETIME                                            
   ,PARCELA     INT                                            
   ,DATARETORNO    DATETIME                                 
   ,DATAENVIO     DATETIME                                            
   ,CODIGO_LAYOUT    INT                                            
  )                        
 END                                            
                                            
 /******************* SELECIONANDO DATA PROCESSAMENTO *******************/                            
 DECLARE @DATA2 DATETIME = NULL                                            
                                            
 IF @DATA IS NULL                                            
 BEGIN                                              
  SET @DATA = CAST(GETDATE() AS DATE)                                              
 END;                                               
                                            
 IF @REPROCESSAR = 1                                            
 BEGIN                                            
 SET @DATA2 = CONVERT(VARCHAR(10), @DATA, 120) + ' 23:59:59'                                            
 END ELSE                                            
 BEGIN                                            
   SET @DATA2 = GETDATE()                                            
 END;                                            
                                            
 /******************* GERANDO ID REMESSA *******************/                                            
 --DECLARE @ID_REMESSA INT = NULL                                            
 --EXEC stpGeraIdRemessaDeepCenter 'MULTICANAL', @ID_REMESSA OUTPUT                                            
                                            
 /******************* DROPANDO TABELAS SELE플O *******************/                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL                                            
 END                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL                                            
 END                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL                                            
 END                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL                                            
 END                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL') IS NOT NULL                                            
 BEGIN                              
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL                                            
 END                                            
                                             
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2               
 END                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_RESPOSTASMSZENVIA_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
 DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_RESPOSTASMSZENVIA_BRADESCO_MULTICANAL                                            
 END                                            
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_AUX_BRADESCODIGITAL_EXPORTACAO_EMAIL_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_AUX_BRADESCODIGITAL_EXPORTACAO_EMAIL_BRADESCO_MULTICANAL                                            
 END                                 
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_JUNCAO_MULTICANAL                                            
 END                                 
                                            
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL                                
 END                                            
                                             
 IF OBJECT_ID ('SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL                                            
 END      
     
  IF OBJECT_ID ('SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT                                            
 END         
                                             
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_PRE_ACIONA_BRADESCO_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_PRE_ACIONA_BRADESCO_MULTICANAL                                            
 END                                              
                             
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVMAIL_MULTICANAL') IS NOT NULL                                            
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVMAIL_MULTICANAL                                            
 END                                            
                                            
 /******************* CRIA플O DAS TABELAS DE SELE플O *******************/                                            
                                            
 /******************* TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL *******************/                                            
 SELECT                                             
  IDCUSTOMER AS CONTRATO_FIN,                                            
  CAST(DATA AS DATE) AS DATA,                                             
  HORA AS HORA,                                             
  TIPO_CANAL AS TIPO_CANAL,                                            
  PHONENUMBER AS PHONENUMBER,                                            
  FORNECEDOR AS FORNECEDOR,                
  NULL AS [EMAIL INEXISTENTE],                                            
  ENTREGA AS ENTREGA,                                            
  E_MAIL AS EMAIL,                                                
  RESPOSTA AS RESPOSTA,                                               
  NAVEGADOR AS NAVEGADOR,                                            
 ABERTO AS ABERTO,                                            
  LIDO AS LIDO,                                            
  ID_ACIONA,                                            
  ID AS ID_SMS,                                    
  MENSAGEM, C.CODACIONAMENTO_DEEP, C.COD_OCORRENCIA, C.COD_CANALACIONAMENTO, C.DESC_MSG      
  ,COD_ACIONAMENTO    
  INTO SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL                                            
 FROM                                            
  AUX_DEEP_CENTER_SMS_MULTICANAIS AS A WITH(NOLOCK)                                    
  OUTER APPLY (                                    
 SELECT C.COD_RESULTADO AS CODACIONAMENTO_DEEP, C.COD_OCORRENCIA, C.COD_CANALACIONAMENTO, D.DESC_MSG, B.COD_ACIONAMENTO                          
 FROM [SRC].DBO.ACIONA AS B (NOLOCK)                                            
 JOIN [DEEPCENTER].CONFIG_ACIONAMENTO AS C ON B.COD_ACIONAMENTO = C.COD_ACIONAMENTO                                    
 JOIN [SRC].DBO.CAD_MSG AS D ON C.COD_FRASE = D.COD_MSG                                
 WHERE A.ID_ACIONA = B.ID                                    
  ) C                                    
 WHERE                               
  [DATA] BETWEEN @DATA AND @DATA2                                             
  AND TIPO_CANAL <> 6                                             
  AND EXISTS (SELECT * FROM [SRC].DBO.CAD_DEVF AS B WHERE A.IDCUSTOMER = B.CONTRATO_FIN AND B.COD_CLI IN (3,11,16,17) 
  AND B.STATCONT_FIN = 0) --OS171361                                            
  AND (                                            
   (ID_ACIONA IS NULL AND NOT EXISTS(SELECT * FROM SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL AS D WHERE D.ID_SMS = A.ID))                                            
   OR                                            
 (ID_ACIONA IS NOT NULL AND NOT EXISTS(SELECT * FROM SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL AS D WHERE D.ID_SMS = A.ID AND D.ID_ACIONA = A.ID_ACIONA))                                            
   )                                    
                           
 SET @QTD_SMS = @@ROWCOUNT                                            
                                            
 CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL(CONTRATO_FIN)                                            
                                            
 SELECT                                            
  IDCUSTOMER,                                            
  CAST(DATA AS DATE) AS DATA,                                             
 HORA AS HORA,                                             
  TIPO_CANAL AS TIPO_CANAL,                                            
  PHONENUMBER AS PHONENUMBER,   
  FORNECEDOR AS FORNECEDOR,                                            
  NULL AS [EMAIL INEXISTENTE],                                            
  ENTREGA AS ENTREGA,                                            
  E_MAIL AS EMAIL,                                                
  RESPOSTA AS RESPOSTA,                            
  NAVEGADOR AS NAVEGADOR,                                            
  ABERTO AS ABERTO,                   
  LIDO AS LIDO,                                            
  ID_ACIONA,                                            
  ID AS ID_SMS,                                    
  MENSAGEM, C.CODACIONAMENTO_DEEP, C.COD_OCORRENCIA, C.COD_CANALACIONAMENTO, C.DESC_MSG       
  ,COD_ACIONAMENTO    
  INTO SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2                                            
 FROM                                            
 AUX_DEEP_CENTER_SMS_MULTICANAIS AS A WITH(NOLOCK)                                    
  OUTER APPLY (                                    
 SELECT C.COD_RESULTADO AS CODACIONAMENTO_DEEP, C.COD_OCORRENCIA, C.COD_CANALACIONAMENTO, D.DESC_MSG, B.COD_ACIONAMENTO                                     
 FROM [SRC].DBO.ACIONA AS B (NOLOCK)                                            
 JOIN [DEEPCENTER].CONFIG_ACIONAMENTO AS C ON B.COD_ACIONAMENTO = C.COD_ACIONAMENTO                                
 JOIN [SRC].DBO.CAD_MSG AS D ON C.COD_FRASE = D.COD_MSG                                
 WHERE A.ID_ACIONA = B.ID                                    
  ) C                                    
 WHERE                        
  [DATA] BETWEEN @DATA AND @DATA2 AND TIPO_CANAL = 6                                             
  AND (                                            
   EXISTS (SELECT * FROM [SRC].DBO.CAD_DEVF AS B with(nolock) WHERE A.IDCUSTOMER = B.contrato_fin AND B.COD_CLI = 3 AND B.STATCONT_FIN = 0)                                            
OR                                            
   EXISTS (SELECT * FROM [SRC].DBO.CAD_DEVF AS B1 with(nolock) WHERE A.IDCUSTOMER = B1.CPF_DEV AND B1.COD_CLI IN (11,16,17) AND B1.STATCONT_FIN = 0)                                                                             
   )                                            
  AND (                                            
   (ID_ACIONA IS NULL AND NOT EXISTS(SELECT * FROM SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL AS D with(nolock) WHERE D.ID_SMS = A.ID))                                            
   OR                                            
   (ID_ACIONA IS NOT NULL AND NOT EXISTS(SELECT * FROM SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL AS D with(nolock)WHERE D.ID_SMS = A.ID AND D.ID_ACIONA = A.ID_ACIONA))                                            
   )                                            
                                            
 SET @QTD_SMS += @@ROWCOUNT                                            
                                            
 CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2(IDCUSTOMER)                                            
                                            
 /******************* TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL *******************/                                            
 SELECT                                            
  A.ID, A.CONTRATO_FIN, A.DATA_ACIONA, A.DDD_TEL, A.TEL_TEL,                                             
  B.TIPOCANALDEEPCENT_ACIONAMENTO, B.FORNECEDORDEEPCENT_ACIONAMENTO,                    
  B.ENTREGAMULTICANAL_ACIONAMENTO, B.ABERTOMULTICANAL_ACIONAMENTO, B.LIDOMULTICANAL_ACIONAMENTO                                    
  ,C.COD_RESULTADO AS CODACIONAMENTO_DEEP, C.COD_OCORRENCIA, C.COD_CANALACIONAMENTO, D.DESC_MSG      
  ,B.COD_ACIONAMENTO    
  INTO SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL                                            
 FROM                                            
  [SRC].DBO.ACIONA AS A (NOLOCK)                                            
  JOIN [SRC].DBO.CAD_ACIONAMENTO AS B (NOLOCK) ON A.COD_ACIONAMENTO = B.COD_ACIONAMENTO                                    
  JOIN [DEEPCENTER].CONFIG_ACIONAMENTO AS C ON A.COD_ACIONAMENTO = C.COD_ACIONAMENTO                                
  LEFT JOIN [SRC].DBO.CAD_MSG AS D ON C.COD_FRASE = D.COD_MSG                                
 WHERE                                            
  A.DATA_ACIONA BETWEEN @DATA AND @DATA2                                            
  AND B.UTILIZADEEPCENTER_ACIONAMENTO = 0                                             
  AND (B.TIPOCANALDEEPCENT_ACIONAMENTO NOT IN (4,10) OR B.WHATSAPPDEEPCENTER_ACIONAMENTO = 0)                                            
  AND EXISTS (SELECT * FROM [SRC].DBO.CAD_DEVF AS C WHERE A.CONTRATO_FIN = C.CONTRATO_FIN AND C.COD_CLI IN (3,11,16,17) AND C.STATCONT_FIN = 0)                                            
  AND NOT EXISTS (SELECT * FROM SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL AS D WHERE D.ID_ACIONA = A.ID)                                            
                                            
 SET @QTD = @@ROWCOUNT                                            
                                            
 CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL(ID)                             
 CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL(CONTRATO_FIN)                                            
 INCLUDE(ID, DATA_ACIONA, DDD_TEL, TEL_TEL, TIPOCANALDEEPCENT_ACIONAMENTO, FORNECEDORDEEPCENT_ACIONAMENTO)                                            
                                            
 IF @QTD = 0 AND @QTD_SMS = 0                                            
 BEGIN                                          
  RETURN;                                            
 END;                                            
               
 /******************* TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL *******************/                                            
 SELECT                                             
  A.CPF_DEV, A.COD_TIPESS,                                            
  B.CONTRATO_FIN, B.VALOR_FIN, B.COD_CLI,                                            
  C.CONTRATO_ORIGINAL,                                            
  E.PHONENUMBER,                                            
  F.PORTFOLIODEEPCENTER_CLI, G.PRODPORTFOLIODEEPCENTER_CAR, G.COD_CAR,                                            
  H.DTACORDO_ACO                                   
  INTO SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL                                            
 FROM                                            
  [SRC].DBO.CAD_DEV AS A (NOLOCK)                                            
  JOIN [SRC].DBO.CAD_DEVF AS B (NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                            
  JOIN [SRC].DBO.AUX_DEVF AS C (NOLOCK) ON B.CONTRATO_FIN = C.CONTRATO_FIN                                            
  OUTER APPLY (SELECT TOP 1 RTRIM(LTRIM(COALESCE(E.DDD_TEL,''))) + RTRIM(LTRIM(COALESCE(E.TEL_TEL,''))) AS PHONENUMBER                                            
      FROM [SRC].DBO.CAD_DEVT AS E WHERE A.CPF_DEV = E.CPF_DEV AND E.CELULARSN_TEL = 0 ORDER BY PERC_TEL DESC) AS E                                            
  JOIN [SRC].DBO.CAD_CLI AS F (NOLOCK) ON B.COD_CLI = F.COD_CLI                                            
  JOIN [SRC].DBO.CAD_CAR_AUX_AUX AS G (NOLOCK) ON B.COD_CLI = G.COD_CLI AND B.COD_CAR = G.COD_CAR                                              
  OUTER APPLY (SELECT TOP 1 DTACORDO_ACO FROM SRC.DBO.CAD_ACO (NOLOCK) AS H                                             
      WHERE B.CONTRATO_FIN = H.CONTRATO_FIN AND H.COD_STAC IN (0,1,3,4,6,7,10,11) ORDER BY NACORDO_ACO DESC) AS H                                            
 WHERE                                            
  (EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL (NOLOCK) AS D WHERE B.CONTRATO_FIN = D.CONTRATO_FIN) --AND B.STATCONT_FIN = 0) --OS165497          
  OR                                             
  EXISTS(SELECT * FROM SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL (NOLOCK) AS X WHERE B.CONTRATO_FIN = X.CONTRATO_FIN)      )                                      
  AND B.COD_CLI IN (3,11,17,16) --OR (B.COD_CLI = 16 AND A.COD_TIPESS = 1))
  AND B.STATCONT_FIN = 0
                                              
 ---------------------------------------------------------------------                                            
                                            
 INSERT SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL(                                            
  CPF_DEV, COD_TIPESS, CONTRATO_FIN, VALOR_FIN, COD_CLI, CONTRATO_ORIGINAL, PHONENUMBER,                    
  PORTFOLIODEEPCENTER_CLI, PRODPORTFOLIODEEPCENTER_CAR, COD_CAR, DTACORDO_ACO                                            
 )                                            
 SELECT                                             
  CPF_DEV, COD_TIPESS, CONTRATO_FIN, VALOR_FIN, COD_CLI, CONTRATO_ORIGINAL, PHONENUMBER,                                            
  PORTFOLIODEEPCENTER_CLI, PRODPORTFOLIODEEPCENTER_CAR, COD_CAR, DTACORDO_ACO                                            
 FROM (                                            
  SELECT                                             
   A.CPF_DEV, A.COD_TIPESS,                                            
   B.CONTRATO_FIN, B.VALOR_FIN, B.COD_CLI,                                     
   C.CONTRATO_ORIGINAL,                                            
   E.PHONENUMBER,                                            
   F.PORTFOLIODEEPCENTER_CLI, G.PRODPORTFOLIODEEPCENTER_CAR, G.COD_CAR,                                            
   H.DTACORDO_ACO, ROW_NUMBER() OVER(PARTITION BY A.CPF_DEV ORDER BY A.CPF_DEV) AS RW                                            
  FROM                                            
   [SRC].DBO.CAD_DEV AS A (NOLOCK)                                            
   JOIN [SRC].DBO.CAD_DEVF AS B (NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                       
   JOIN [SRC].DBO.AUX_DEVF AS C (NOLOCK) ON B.CONTRATO_FIN = C.CONTRATO_FIN                                            
   OUTER APPLY (SELECT TOP 1 RTRIM(LTRIM(COALESCE(E.DDD_TEL,''))) + RTRIM(LTRIM(COALESCE(E.TEL_TEL,''))) AS PHONENUMBER                                             
       FROM [SRC].DBO.CAD_DEVT AS E WHERE A.CPF_DEV = E.CPF_DEV AND E.CELULARSN_TEL = 0 ORDER BY PERC_TEL DESC) AS E                                            
   JOIN [SRC].DBO.CAD_CLI AS F (NOLOCK) ON B.COD_CLI = F.COD_CLI                                            
   JOIN [SRC].DBO.CAD_CAR_AUX_AUX AS G (NOLOCK) ON B.COD_CLI = G.COD_CLI AND B.COD_CAR = G.COD_CAR                                              
   OUTER APPLY (SELECT TOP 1 DTACORDO_ACO FROM SRC.DBO.CAD_ACO (NOLOCK) AS H                                             
       WHERE B.CONTRATO_FIN = H.CONTRATO_FIN AND H.COD_STAC IN (0,1,3,4,6,7,10,11) ORDER BY NACORDO_ACO DESC) AS H                                            
  WHERE                                               
   (EXISTS(SELECT * FROM SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 (NOLOCK) AS X WHERE B.CPF_DEV = X.IDCUSTOMER AND B.COD_CLI = 11 AND B.STATCONT_FIN = 0)                                      
    OR EXISTS(SELECT * FROM SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 (NOLOCK) AS X3 WHERE B.CONTRATO_FIN = X3.IDCUSTOMER AND B.COD_CLI IN (3,17,16) AND B.STATCONT_FIN = 0))                                      
 --OR EXISTS(SELECT * FROM SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 (NOLOCK) AS X4 WHERE B.CONTRATO_FIN = X4.IDCUSTOMER AND B.COD_CLI = 16))                                            
   AND NOT EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS X2 WITH(NOLOCK) WHERE X2.CONTRATO_FIN = B.CONTRATO_FIN AND B.STATCONT_FIN = 0)                                            
   --AND B.COD_CLI = 11                                      
 ) AS Y                           
 WHERE RW = 1                                            
                                            
 CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL(CONTRATO_FIN)                                             
 INCLUDE(CPF_DEV, COD_TIPESS, VALOR_FIN, CONTRATO_ORIGINAL)                                            
                                            
 /******************* TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL *******************/                                            
 SELECT                                             
  CONTRATO_FIN, CARTEIRA, CASE WHEN NOMEPRODUTO = '' THEN NULL ELSE NOMEPRODUTO END AS SUBPRODUTO, A.COD_EMPRESA                                            
  INTO SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL                                            
 FROM                                             
  [SRC].DBO.AUX_BRADESCOBANCO AS A  (NOLOCK)                                             
  LEFT JOIN [SRC].DBO.BRADESCOPRODUTOS AS B ON (B.CODPRODUTO = A.CARTEIRA)                                                 
 WHERE                                            
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                            
                                      
 /******************* TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL *******************/                                      
 SELECT           
  CONTRATO_FIN, CARTEIRA, COD_NATUREZA AS PRODUTO, DESC_NATUREZA AS SUBPRODUTO, TITULO, AGENCIA, CONTA,                                      
  AGENCIA_CLIENTE, CONTA_CLIENTE, NUMERO_CARTEIRA                                      
  INTO SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL                                      
 FROM                                      
  [SRC].DBO.AUX_BRADESCOLPTITULO AS A WITH(NOLOCK)                                      
 WHERE                                      
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                    
                            
                                            
 /******************* TBL_SELECAO_CAD_DEVMAIL_MULTICANAL *******************/                                            
 SELECT                                            
  B.CONTRATO_FIN, A.DESC_DEVMAIL                                            
  INTO SRC.DeepCenter.TBL_SELECAO_CAD_DEVMAIL_MULTICANAL                                            
 FROM                                      
  [SRC].DBO.CAD_DEVMAIL AS A WITH(NOLOCK)                                            
  JOIN SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WITH(NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                            
 WHERE                                            
  A.PERC_MAIL > 0                                
                                            
 /******************* TBL_JUNCAO_MULTICANAL *******************/                                            
 SELECT                                             
  * INTO SRC.DeepCenter.TBL_JUNCAO_MULTICANAL                                            
 FROM                                            
  (                                            
   SELECT                                             
    A.CONTRATO_FIN,                                             
    CAST(A.DATA_ACIONA AS DATE) AS DATA,                                             
    CAST(A.DATA_ACIONA AS TIME) AS HORA,                                           
    A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPO_CANAL,                                            
    RTRIM(LTRIM(COALESCE(A.DDD_TEL,''))) + RTRIM(LTRIM(COALESCE(A.TEL_TEL,''))) AS PHONENUMBER,                                            
    CAST(A.FORNECEDORDEEPCENT_ACIONAMENTO AS VARCHAR(100)) AS FORNECEDOR,                                            
    NULL AS [EMAIL INEXISTENTE],                                            
    A.ENTREGAMULTICANAL_ACIONAMENTO AS ENTREGA,                                            
    NULL AS EMAIL,                                                
    IIF(B.RESPOSTA = 'SIM', 1, 2) AS RESPOSTA,                                               
    NULL AS NAVEGADOR,                                            
    A.ABERTOMULTICANAL_ACIONAMENTO AS ABERTO,                                            
   A.LIDOMULTICANAL_ACIONAMENTO AS LIDO,                                            
                                            
    A.ID AS ID_ACIONA,                                            
    NULL AS ID_SMS,                                     
    0 AS FLAG                                    
 ,NULL AS MENSAGEM,A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG         
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL AS A WITH(NOLOCK)                                            
    LEFT JOIN SRC.DBO.AUX_RETORNO_ZENVIA (NOLOCK) AS B ON A.ID = B.ID_ACIONA                                
   WHERE                                            
    A.TIPOCANALDEEPCENT_ACIONAMENTO <> 6                                            
                                            
   UNION ALL                                            
 -- SOLICITA플O FEITA NA OS 162965 PARA ENVIAR UMA LINHA PARA CADA EMAIL DO CPF                                            
   SELECT                                             
    A.CONTRATO_FIN,                                             
    CAST(A.DATA_ACIONA AS DATE) AS DATA,                                    
    CAST(A.DATA_ACIONA AS TIME) AS HORA,                                             
    A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPO_CANAL,                                            
    NULL AS PHONENUMBER,                                            
    CAST(A.FORNECEDORDEEPCENT_ACIONAMENTO AS VARCHAR(100)) AS FORNECEDOR,                                            
    NULL AS [EMAIL INEXISTENTE],                                            
    A.ENTREGAMULTICANAL_ACIONAMENTO AS ENTREGA,                                            
    B.DESC_DEVMAIL AS EMAIL,                             
    2 AS RESPOSTA,                                               
    NULL AS NAVEGADOR,                                            
    A.ABERTOMULTICANAL_ACIONAMENTO AS ABERTO,                                            
    A.LIDOMULTICANAL_ACIONAMENTO AS LIDO,                                            
                                            
    A.ID AS ID_ACIONA,                                            
    NULL AS ID_SMS,                                            
    0 AS FLAG                                    
 ,NULL AS MENSAGEM,A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG        
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL AS A WITH(NOLOCK)                                            
    JOIN SRC.DeepCenter.TBL_SELECAO_CAD_DEVMAIL_MULTICANAL AS B WITH(NOLOCK) ON A.CONTRATO_FIN = B.CONTRATO_FIN                                            
   WHERE                                 
    A.TIPOCANALDEEPCENT_ACIONAMENTO = 6                                            
    AND EXISTS (SELECT * FROM SRC.DBO.EVENTO AS B WITH(NOLOCK)                                            
       WHERE B.CONTRATO_FIN = A.CONTRATO_FIN AND B.COD_EVENTO = 472                                            
       AND CONVERT(VARCHAR(13),A.DATA_ACIONA,120) = CONVERT(VARCHAR(13),B.DATA_EVENTO,120) )                                            
   UNION ALL                                            
   SELECT                                             
    CONTRATO_FIN,           
    DATA,                                             
    HORA,                                             
    TIPO_CANAL,                                            
    PHONENUMBER,                          
    FORNECEDOR,                                            
    [EMAIL INEXISTENTE],                                            
    ENTREGA,                                            
    EMAIL,                                                
RESPOSTA,                                               
    NAVEGADOR,                                            
    ABERTO,                                            
    LIDO,                                            
    ID_ACIONA,                                            
    ID_SMS,                                            
    1 AS FLAG                                    
 ,MENSAGEM, A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG          
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL A WITH(NOLOCK)                                            
                                            
   UNION ALL                                            
                 
   SELECT                                            
    B.CONTRATO_FIN, DATA, HORA, TIPO_CANAL,A.PHONENUMBER,FORNECEDOR,[EMAIL INEXISTENTE],                                            
    ENTREGA,EMAIL,RESPOSTA,NAVEGADOR,ABERTO,LIDO,ID_ACIONA,ID_SMS,1 AS FLAG                                    
 ,MENSAGEM, A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG      
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 AS A WITH(NOLOCK)                                            
    JOIN SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WITH(NOLOCK) ON A.IDCUSTOMER = B.CPF_DEV AND B.COD_CLI = 11                                            
                                            
   UNION ALL                                        
                                            
   SELECT                                            
    B.CONTRATO_FIN, DATA, HORA, TIPO_CANAL,A.PHONENUMBER,FORNECEDOR,[EMAIL INEXISTENTE],                                            
    ENTREGA,EMAIL,RESPOSTA,NAVEGADOR,ABERTO,LIDO,ID_ACIONA,ID_SMS,1 AS FLAG                                    
 ,MENSAGEM, A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG     
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 AS A WITH(NOLOCK)                                            
    JOIN SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WITH(NOLOCK) ON A.IDCUSTOMER = B.CONTRATO_FIN AND B.COD_CLI = 3                                            
                                    
   UNION ALL                                            
                                            
   SELECT                                            
    B.CONTRATO_FIN, DATA, HORA, TIPO_CANAL,A.PHONENUMBER,FORNECEDOR,[EMAIL INEXISTENTE],                                            
    ENTREGA,EMAIL,RESPOSTA,NAVEGADOR,ABERTO,LIDO,ID_ACIONA,ID_SMS,1 AS FLAG                                    
 ,MENSAGEM, A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG       
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 AS A WITH(NOLOCK)                                            
    JOIN SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WITH(NOLOCK) ON A.IDCUSTOMER = B.CONTRATO_FIN AND B.COD_CLI = 16            
           
   UNION ALL                                            
                                 
   SELECT                                            
    B.CONTRATO_FIN, DATA, HORA, TIPO_CANAL,A.PHONENUMBER,FORNECEDOR,[EMAIL INEXISTENTE],                                            
    ENTREGA,EMAIL,RESPOSTA,NAVEGADOR,ABERTO,LIDO,ID_ACIONA,ID_SMS,1 AS FLAG                                    
 ,MENSAGEM, A.CODACIONAMENTO_DEEP, A.COD_OCORRENCIA, A.COD_CANALACIONAMENTO, A.DESC_MSG       
 ,COD_ACIONAMENTO    
   FROM                                            
    SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL_2 AS A WITH(NOLOCK)                                            
    JOIN SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WITH(NOLOCK) ON A.IDCUSTOMER = B.CONTRATO_FIN AND B.COD_CLI = 17           
 )                                            
 AS X                                                
                                            
 /******************* TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL *******************/                                            
 SELECT                                            
  A.CONTRATO_FIN, A.PARCELA_PARC, A.VENC_PARC, A.VALOR_PARC, A.COD_STPA                                            
  INTO SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL                                            
 FROM                                            
  [SRC].DBO.CAD_DEVP AS A (NOLOCK)                               
 WHERE                                            
  COD_STPA = 0 AND VENC_PARC < GETDATE()  AND                                            
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                            
                                            
 /******************* TBL_BRADESCO_DIGITAL_FINAL_MULTICANAL *******************/                                            
 SELECT                                            
  @DATA AS DATA,                                            
  B.HORA,                                            
  CASE WHEN COALESCE(A.COD_TIPESS,0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(A.CPF_DEV)), 14)                                             
  ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(A.CPF_DEV)), 11) END AS IDCUSTOMER,                                              
                                                
  CASE                                             
   WHEN COALESCE(A.COD_TIPESS,0) = 1 THEN ''                                             
   ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(A.CPF_DEV)), 11)                                
  END AS CPF,                                            
                                              
  CASE                                            
   WHEN COALESCE(A.COD_TIPESS,0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(A.CPF_DEV)), 14)                                             
   ELSE ''                                             
  END AS CNPJ,                                            
                                            
  --COALESCE(A.CONTRATO_ORIGINAL,                                                  
  --   (CASE WHEN CHARINDEX('-', A.CONTRATO_FIN) > 1 THEN LEFT(A.CONTRATO_FIN, CHARINDEX('-', A.CONTRATO_FIN)-1) ELSE A.CONTRATO_FIN END)                                      
  --) AS CONTRATO,                                            
                                      
    CASE                                         
  WHEN A.COD_CLI IN (16,17) THEN COALESCE(K.TITULO, A.CONTRATO_ORIGINAL)                                      
  WHEN A.CONTRATO_ORIGINAL IS NOT NULL THEN A.CONTRATO_ORIGINAL                                            
  WHEN CHARINDEX('-', A.CONTRATO_FIN) > 1 THEN LEFT(A.CONTRATO_FIN, CHARINDEX('-', A.CONTRATO_FIN)-1)                                      
  ELSE A.CONTRATO_FIN                                       
  END AS CONTRATO,                                      
                
  3 AS SEGMENTOCANAL,                                            
                                 
  CASE                                            
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '3A52' THEN  6 -- OS168675                                        
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '2A52' THEN 23                                            
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '4A53' THEN 24                                  
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '7A51' THEN 25                                            
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '8A51' THEN 26                                        
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '6A51' THEN 40 -- OS167390                                        
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '1A52' THEN 41 -- OS167390                                        
  WHEN A.COD_CLI = 11             THEN 27                                            
  --WHEN D.COD_EMPRESA = 'ABLG0000'          THEN 6                                            
  WHEN R.CPF_DEV IS NOT NULL           THEN 6                                         
  ELSE A.PORTFOLIODEEPCENTER_CLI                
  END AS PORTFOLIO,                                            
                                            
  CASE                               
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '3A52' THEN 39                                            
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '2A52' THEN 40                                            
  --WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '4A53' THEN 41                                            
  WHEN A.COD_CLI = 11 AND COALESCE(A.COD_TIPESS,0) = 0 AND SUBSTRING(ltrim(G.FILLER), 3, 3) = 'A53'  THEN 1019 -- OS170702                                              
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '7A51' THEN 42                                            
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '8A51' THEN 43                                        
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '6A51' THEN 52 -- OS167390                                       
  WHEN A.COD_CLI = 11 AND SUBSTRING(G.FILLER, 3, 5) = '1A52' THEN 53 -- OS167390                                      
  WHEN A.COD_CLI = 11     THEN 44                                            
  --WHEN D.COD_EMPRESA = 'ABLG0000'          THEN 1                                            
  WHEN R.CPF_DEV IS NOT NULL           THEN  1 -- OS168675                                              
  ELSE A.PRODPORTFOLIODEEPCENTER_CAR                                            
  END AS PRODUTOPORTFOLIO,                                            
                                            
  --IIF(A.PORTFOLIODEEPCENTER_CLI = 7, 'EAVM', D.CARTEIRA) AS CARTEIRA,                                            
   CASE                             
 WHEN A.COD_CLI IN (16,17) THEN SUBSTRING(K.CARTEIRA,PATINDEX('%[a-z,1-9]%',K.CARTEIRA),LEN(K.CARTEIRA ))                                      
 WHEN A.PORTFOLIODEEPCENTER_CLI = 7 THEN 'EAVM'                                      
 ELSE D.CARTEIRA                                      
 END AS CARTEIRA,                                      
                                      
  --IIF(A.PORTFOLIODEEPCENTER_CLI = 7, G.DESCRIAO, D.SUBPRODUTO) AS PRODUTO,                                   
  CASE                                      
 WHEN A.COD_CLI IN (16,17) THEN K.SUBPRODUTO                                      
 WHEN A.PORTFOLIODEEPCENTER_CLI = 7 THEN G.DESCRIAO                                      
 ELSE D.SUBPRODUTO                                      
  END AS PRODUTO,                                
                                      
  IIF(A.PORTFOLIODEEPCENTER_CLI = 7, G.DESCRIAO, NULL) AS SUBPRODUTO,                                            
  B.TIPO_CANAL AS TIPOCANAL,                                            
                                              
  IIF(B.TIPO_CANAL = 6, NULL,                                             
   IIF(COALESCE(H.PHONENUMBER,'') = '',                          
      IIF(B.PHONENUMBER IN ('ATIVO', 'RECEPTIVO'), A.PHONENUMBER,B.PHONENUMBER), H.PHONENUMBER)) AS PHONENUMBER,                                              
                                              
  IIF(COALESCE(H.FORNECEDOR,'') = '', B.FORNECEDOR, H.FORNECEDOR) AS FORNECEDOR,                                            
  B.[EMAIL INEXISTENTE],                                            
  IIF(COALESCE(H.ENTREGA,'') = '', B.ENTREGA, H.ENTREGA) AS ENTREGA,                        
  B.EMAIL,                                            
  IIF(COALESCE(H.RESPOSTA,'') = '', B.RESPOSTA, H.RESPOSTA) AS RESPOSTA,                                            
  B.NAVEGADOR,                                            
  IIF(COALESCE(H.ABERTO,'') = '', B.ABERTO, H.ABERTO) AS ABERTO,                                            
  IIF(COALESCE(H.LIDO,'') = '', B.LIDO, H.LIDO) AS LIDO,                                            
  A.VALOR_FIN AS VLRPRINC,                                            
  C.VLRATRASO,                                            
  C.PARCELAATRASO,                                            
  IIF(B.TIPO_CANAL = 15, IIF(E.STATUS_LINK = 'VISUALIZADO',1,0), NULL) AS OPTIAGENDA,                                            
                                            
  A.DTACORDO_ACO AS DATAACORDO, /*********/                                            
  1 AS PARCELA,                                            
  E.DATA_ABERTURA AS DATARETORNO,                                            
  E.DATA_ENTRADA AS DATAENVIO,                                              
  0 AS CODIGO_LAYOUT,                                            
                                            
  B.COD_ACIONAMENTO,                                            
  COALESCE(B.ID_SMS, H.ID) AS ID_SMS,                                            
  B.FLAG,                                            
  ROW_NUMBER() OVER(ORDER BY B.ID_ACIONA) AS ID                                             
  ,B.MENSAGEM, B.CODACIONAMENTO_DEEP, B.COD_OCORRENCIA, B.COD_CANALACIONAMENTO, B.DESC_MSG    
  ,B.ID_ACIONA    
  INTO SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL                                            
 FROM                                            
  SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL AS A                                            
  JOIN SRC.DeepCenter.TBL_JUNCAO_MULTICANAL AS B ON A.CONTRATO_FIN = B.CONTRATO_FIN                                              
                                             
  CROSS APPLY ( SELECT                                 
      SUM(C.VALOR_PARC) AS VLRATRASO,                                            
      MIN(C.PARCELA_PARC) AS PARCELAATRASO,                                            
      MIN(C.VENC_PARC) AS DATAATRASO                                            
       FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL AS C                                            
       WHERE A.CONTRATO_FIN = C.CONTRATO_FIN                                            
       ) AS C                                            
                                            
  OUTER APPLY (SELECT TOP 1 * FROM SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL AS D WHERE A.CONTRATO_FIN = D.CONTRATO_FIN) AS D                                            
  OUTER APPLY (SELECT TOP 1 STATUS_LINK, DATA_ABERTURA, DATA_ENTRADA FROM SRC.DBO.AUX_GENIONTECHNOLOGY AS E                                             
      WHERE E.IDENTIFICADOR = A.CONTRATO_FIN AND COALESCE(B.PHONENUMBER, A.PHONENUMBER) = E.TELEFONE                                            
      AND B.[DATA] = CAST(E.DATA_EXPORTACAO AS DATE)                                            
      AND CAST(LEFT(B.HORA, 8) AS TIME) BETWEEN                                                                   
       DATEADD (MILLISECOND, -60000, CAST(RIGHT(LEFT(CONVERT(VARCHAR(50),E.DATA_EXPORTACAO, 121), 19), 8) AS TIME)) AND                           
       DATEADD (MILLISECOND, 60000, CAST(RIGHT(LEFT(CONVERT(VARCHAR(50),E.DATA_EXPORTACAO, 121), 19), 8) AS TIME))                                            
      ORDER BY E.DATA_EXPORTACAO DESC) AS E                                            
                                            
  --LEFT JOIN TBL_BKP_PORTFOLIO_DEEPCENTER AS F ON A.COD_CLI = F.COD_CLI AND A.COD_CAR = F.COD_CAR                                        
                                     
  OUTER APPLY (SELECT TOP 1 DESCRIAO, FILLER FROM AUX_CARTOESBRADESCO (NOLOCK) AS G WHERE G.CONTRATO_FIN = A.CONTRATO_FIN) AS G                                            
                         
  LEFT JOIN AUX_DEEP_CENTER_SMS_MULTICANAIS AS H ON B.ID_ACIONA = H.ID_ACIONA AND B.FLAG = 0                                            
                                      
  OUTER APPLY (SELECT TOP 1 * FROM SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL AS K WHERE A.CONTRATO_FIN = K.CONTRATO_FIN) AS K                                      
                                            
  LEFT JOIN SRC.dbo.TBL_BRADESCO_PORTOLIO_35 AS R WITH (NOLOCK) ON R.CPF_DEV = A.CPF_DEV                                        
                              
 --DECLARE @VLR_INI INT = 1, @VLR_FIN INT = 1000, @BLOCO INT = 1000                                            
 SET @VLR_INI = 1                                            
 SET @VLR_FIN = @BLOCO          
         
 /******************* TABELA FINAL DEEPCENTER *******************/                                                            
                       
 SELECT         
  'MLGomes' AS DSNOMEASSESSORIA,         
  GETDATE() AS DTDATAINSERCAO,        
  [DATA] AS DTDATAREFERENCIA,         
  HORA AS HRHORAINICIO,         
  HORA AS HRHORAFIM,         
  NULL AS NUMTEMPOFALADO,         
  NULL AS NUMTEMPOESPERA,         
  NULL AS DSIDAGENT,         
  NULL AS DSNOMEAGENT,         
  LEFT(PHONENUMBER,11) AS NUMTELEFONE,                   
  LEFT(CONTRATO,100) AS NUMCONTRACT,         
  IIF(CPF IN ('','0'),CNPJ,CPF) AS NUMCUSTOMER,         
  IIF(CPF IN ('','0'),CNPJ,CPF) AS NUMCLIENTE,         
  3 AS NUMSEGMENTO,         
  NULL AS IDORIGEMTELEFONE,         
  NULL AS IDTIPODISCAGEM,         
  1 AS IDORIGEMATENDIMENTO,         
  COALESCE(COD_CANALACIONAMENTO,TIPOCANAL) AS IDCANALACIONAMENTO,         
  LEFT(EMAIL,100) AS DSEMAIL,         
  0 AS DSIDCALL,                                    
  NULL AS IDDESLIGADOPOR,         
  COALESCE(CODACIONAMENTO_DEEP,COD_OCORRENCIA,0) AS IDRESULTADO,         
  COALESCE(COD_OCORRENCIA,0) AS IDOCORRENCIA,        
  0 AS IDMOTIVOINAD,        
  VLRATRASO AS VLRACORDO,        
  PARCELAATRASO AS NUMPLANO,        
  NULL AS IDGRAVACAO,       
  LEFT(DESC_MSG,144) AS DSFRASE,        
  0 AS NUMPARCELA,        
  COD_ACIONAMENTO,    
  ID_ACIONA    
 INTO DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT        
 FROM DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL        
        
 CREATE NONCLUSTERED INDEX NON_IX_COD_ACIONAMENTO ON DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT (COD_ACIONAMENTO);        
        
 CREATE NONCLUSTERED INDEX NON_IX_IDCANALACIONAMENTO ON DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT (IDCANALACIONAMENTO);        
         
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT        
 SET  IDOCORRENCIA = 0, IDORIGEMATENDIMENTO = 0, DSIDCALL = '', IDRESULTADO = 0, IDTIPODISCAGEM = NULL        
 WHERE IDCANALACIONAMENTO IN (6, 8, 12, 13, 14, 16)        
        
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT        
 SET  IDOCORRENCIA = 0, IDORIGEMATENDIMENTO = 0, DSIDCALL = '', IDRESULTADO = 0, IDTIPODISCAGEM = NULL        
 ,IDCANALACIONAMENTO = 19        
 WHERE COD_ACIONAMENTO = 8272        
        
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT        
 SET  IDOCORRENCIA = 0, IDORIGEMATENDIMENTO = 0, DSIDCALL = '', IDRESULTADO = 0, IDTIPODISCAGEM = NULL        
 ,IDCANALACIONAMENTO = 19        
 WHERE COD_ACIONAMENTO = 8272        
        
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 504,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8353        
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 507,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8354       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 509,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8355       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 402,IDMOTIVOINAD = 0,IDRESULTADO = 4 WHERE COD_ACIONAMENTO = 8356       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 406,IDMOTIVOINAD = 0,IDRESULTADO = 4 WHERE COD_ACIONAMENTO = 8357       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 507,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8358       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 509,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8359       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 507,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8360       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 503,IDMOTIVOINAD = 0,IDRESULTADO = 5 WHERE COD_ACIONAMENTO = 8361       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 2,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8362       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 603,IDMOTIVOINAD = 0,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8363       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 604,IDMOTIVOINAD = 0,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8364       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 8,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8365       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 703,IDMOTIVOINAD = 0,IDRESULTADO = 7 WHERE COD_ACIONAMENTO = 8366       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 703,IDMOTIVOINAD = 0,IDRESULTADO = 7 WHERE COD_ACIONAMENTO = 8367       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 703,IDMOTIVOINAD = 0,IDRESULTADO = 7 WHERE COD_ACIONAMENTO = 8368       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 703,IDMOTIVOINAD = 0,IDRESULTADO = 7 WHERE COD_ACIONAMENTO = 8369       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 702,IDMOTIVOINAD = 0,IDRESULTADO = 7 WHERE COD_ACIONAMENTO = 8370       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 3,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8371       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 6,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8372       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 7,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8373       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 1,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8374       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 1,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8375       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 702,IDMOTIVOINAD = 0,IDRESULTADO = 7 WHERE COD_ACIONAMENTO = 8376       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 603,IDMOTIVOINAD = 0,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8377       
 UPDATE DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT SET IDCANALACIONAMENTO = 19,  IDOCORRENCIA = 606,IDMOTIVOINAD = 4,IDRESULTADO = 6 WHERE COD_ACIONAMENTO = 8373       
                                            
 /******************* TABELA FINAL DEEPCENTER *******************/                                        
                                     
  INSERT [DeepCenter].[FINAL_ACIONAMENTO](                                                                
   DSNOMEASSESSORIA,DTDATAINSERCAO,DTDATAREFERENCIA,HRHORAINICIO,HRHORAFIM,NUMTEMPOFALADO,NUMTEMPOESPERA,DSIDAGENT,DSNOMEAGENT,NUMTELEFONE,                                    
   NUMCONTRACT,NUMCUSTOMER,NUMCLIENTE,NUMSEGMENTO,IDORIGEMTELEFONE,IDTIPODISCAGEM,IDORIGEMATENDIMENTO,IDCANALACIONAMENTO,DSEMAIL,DSIDCALL,                                            
   IDDESLIGADOPOR,IDRESULTADO,IDOCORRENCIA,IDMOTIVOINAD,VLRACORDO,NUMPLANO,IDGRAVACAO,DSFRASE,NUMPARCELA                                            
  )                                         
  SELECT DSNOMEASSESSORIA,DTDATAINSERCAO,DTDATAREFERENCIA,HRHORAINICIO,HRHORAFIM,NUMTEMPOFALADO,NUMTEMPOESPERA,DSIDAGENT,DSNOMEAGENT,NUMTELEFONE,                                    
   NUMCONTRACT,NUMCUSTOMER,NUMCLIENTE,NUMSEGMENTO,IDORIGEMTELEFONE,IDTIPODISCAGEM,IDORIGEMATENDIMENTO,IDCANALACIONAMENTO,DSEMAIL,DSIDCALL,                                            
   IDDESLIGADOPOR,IDRESULTADO,IDOCORRENCIA,IDMOTIVOINAD,VLRACORDO,NUMPLANO,IDGRAVACAO,DSFRASE,NUMPARCELA                                    
   --'MLGomes', GETDATE(),DATA, HORA, HORA, NULL, NULL, NULL, NULL, LEFT(PHONENUMBER,11),                   
   --LEFT(A.CONTRATO,100), IIF(A.CPF IN ('','0'),A.CNPJ,A.CPF), IIF(A.CPF IN ('','0'),A.CNPJ,A.CPF), 3, NULL, NULL, 1, COALESCE(COD_CANALACIONAMENTO,TIPOCANAL), LEFT(EMAIL,100), 0,                                    
   --NULL, COALESCE(CODACIONAMENTO_DEEP,COD_OCORRENCIA,0), COALESCE(COD_OCORRENCIA,0),0,VLRATRASO,PARCELAATRASO,NULL,LEFT(DESC_MSG,144),0                                                    
  FROM                                            
   SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT                                           
   --JOIN SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL AS B ON A.ID_ACIONA = B.ID_ACIONA                            
                      
  ----Controle MultiCanal                    
  INSERT SRC.DeepCenter.TBL_DEEPCENTER_CONTROLE_MULTICANAL(ID_ACIONA, ID_SMS)                                            
  SELECT ID_ACIONA, ID_SMS FROM SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL AS A (NOLOCK)                                             
                                            
 --WHILE 1=1                                            
 --BEGIN                                        
 -- DELETE TOP (1000) A                                            
 -- OUTPUT                                            
 --  B.DATAINSERT,DELETED.DATA,DELETED.HORA,DELETED.IDCUSTOMER,DELETED.CPF,DELETED.CNPJ,                                            
 --  DELETED.CONTRATO,DELETED.SEGMENTOCANAL,DELETED.PORTFOLIO,DELETED.PRODUTOPORTFOLIO,DELETED.CARTEIRA,                                            
 --  DELETED.PRODUTO,DELETED.SUBPRODUTO,DELETED.TIPOCANAL,DELETED.PHONENUMBER,DELETED.FORNECEDOR,                                            
 --  DELETED.[EMAIL INEXISTENTE],DELETED.ENTREGA,DELETED.EMAIL,DELETED.RESPOSTA,DELETED.NAVEGADOR,                                   
 --  DELETED.ABERTO,DELETED.LIDO,DELETED.VLRPRINC,DELETED.VLRATRASO,DELETED.PARCELAATRASO,DELETED.OPTIAGENDA,                                            
 --  DELETED.DATAACORDO, DELETED.PARCELA, DELETED.DATARETORNO, DELETED.DATAENVIO, DELETED.CODIGO_LAYOUT                                            
                                            
 -- INTO SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_MULTICANAL_FINAL                                            
 -- (                                            
 --  DATAINSERT,DATA,HORA,IDCUSTOMER,CPF,CNPJ,                                            
 --  CONTRATO,SEGMENTOCANAL,PORTFOLIO,PRODUTOPORTFOLIO,CARTEIRA,                                            
 --  PRODUTO,SUBPRODUTO,TIPOCANAL,PHONENUMBER,FORNECEDOR,                                            
 --  [EMAIL INEXISTENTE],ENTREGA,EMAIL,RESPOSTA,NAVEGADOR,                                            
 --  ABERTO,LIDO,VLRPRINC,VLRATRASO,PARCELAATRASO,OPTIAGENDA,                                            
 --  DATAACORDO, PARCELA, DATARETORNO, DATAENVIO, CODIGO_LAYOUT                                            
 -- )                                            
 -- FROM                                            
 --  SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL AS A                                           
 --  JOIN TBL_DEEPCENTER_CONTROLE_MULTICANAL AS B ON A.ID_SMS = B.ID_SMS AND A.FLAG = 1                                            
                                            
 -- IF @@ROWCOUNT < 1000 BREAK                                            
 --END                                            
                                            
 /******************* DROPANDO TABELAS SELE플O *******************/                 
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_ACIONA_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_AUX_DEEP_CENTER_SMS_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_RESPOSTASMSZENVIA_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_RESPOSTASMSZENVIA_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_AUX_BRADESCODIGITAL_EXPORTACAO_EMAIL_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_AUX_BRADESCODIGITAL_EXPORTACAO_EMAIL_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_JUNCAO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_MULTICANAL                                            
 --END                                            
              
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                            
 -- DROP TABLE SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL                                            
 --END            
     
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT') IS NOT NULL                                            
 --BEGIN                                       
 -- DROP TABLE SRC.DeepCenter.TBL_BRADESCO_FINAL_MULTICANAL_INSERT                                            
 --END     
                                             
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_PRE_ACIONA_BRADESCO_MULTICANAL') IS NOT NULL                                            
 --BEGIN                                      
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_PRE_ACIONA_BRADESCO_MULTICANAL                                            
 --END                                            
                                            
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVMAIL_MULTICANAL') IS NOT NULL                                            
 --BEGIN                        
 -- DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVMAIL_MULTICANAL                                            
 --END                                            
                                             
 EXEC stpGravaLogDeepCenter @ID_LOG                                            
                                            
END TRY                                            
BEGIN CATCH                                            
 EXEC STP_LOG_ERRO 'ExecucaoDeepCenterlBradescoComercialMulticanal'                                            
END CATCH
GO


