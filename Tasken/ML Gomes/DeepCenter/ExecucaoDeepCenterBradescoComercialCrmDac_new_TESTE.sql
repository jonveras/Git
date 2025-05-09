USE [SRC]
GO

/****** Object:  StoredProcedure [dbo].[ExecucaoDeepCenterBradescoComercialCrmDac_new]    Script Date: 07/05/2025 13:47:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ExecucaoDeepCenterBradescoComercialCrmDac_new](
 @DATA DATETIME = NULL, @Reprocessar bit = 0                                                  
)                                                    
AS                                                    
/* *********************************************************************************************** *                                                  
 * NOME DO OBJETO : ExecucaoDeepCenterBradescoComercialCrmDac                 *                                                  
 * CRIAÇÃO: 12/09/2019                      *                                                  
 * PROFISSIONAL: LUCAS LIMA                     *                                                  
 * PROJETO: DEEPCENTER                      *                                                   
 * *********************************************************************************************** */                                                  
BEGIN TRY                                                    
                                                     
 DECLARE @ID_LOG_GERAL INT                                                    
 EXEC stpGravaLogDeepCenter 0, 'COMERCIAL-CARTAO', 'CRMDAC', @ID_LOG_GERAL OUTPUT                                                    
                                                    
 /****************************************************** TABELA DE CONTROLE ************************************************************/                                                    
 IF OBJECT_ID('SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC') IS NULL                                                    
 BEGIN                                                    
  CREATE TABLE SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC                                                    
  (                                                    
   ID BIGINT IDENTITY(1,1),                                                    
   IDCALL BIGINT,                                                  
   ID_ACIONA INT,                                                  
   DATA_REGISTRO DATETIME DEFAULT(GETDATE()),                                                  
   IDCALL_SINERGYTECH BIGINT                                                  
  )                                                  
                                                    
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC(IDCALL)                                                    
  CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC(ID_ACIONA)                                                    
  CREATE CLUSTERED INDEX CL_IX ON SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC(ID)                                                    
  CREATE NONCLUSTERED INDEX NON_IX3 ON SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC(IDCALL_SINERGYTECH)                                                    
 END                                                    
                                                    
 /*************************** CRIA A TABELA CASO NÃO EXISTA ***************************************/                                                    
 IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CRMDAC_FINAL') IS NULL                                                    
 BEGIN                                                    
  CREATE TABLE SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CRMDAC_FINAL                                                    
  (                                                    
   IDUNICO BIGINT    IDENTITY(1,1)                                                    
  ,DATAINSERT     DATETIME CONSTRAINT DF_DATA_INSERT_CRMDAC1 DEFAULT(GETDATE())                                                    
  ,IDCALL      VARCHAR(500)                   
  ,DATA DATE        
  ,HORA      VARCHAR(8)                                   
  ,AGENTE      VARCHAR(50)                                                    
  ,IDAGENT VARCHAR(50)                                                    
  ,IDCUSTOMER     VARCHAR(20)                                                   
  ,CPF      VARCHAR(14)                            
  ,CNPJ      VARCHAR(14)                                                    
  ,CONTRATO     VARCHAR(50)                                                    
  ,IDOCORRENCIA    INT                                    
  ,DESCOCORRENCIA    VARCHAR(60)                                                    
  ,PHONENUMBER    VARCHAR(20)                                                    
  ,TIPODISCAGEM    INT                               
  ,TIPOATENDIMENTO   INT                                                    
  ,ORIGEMTEL     INT                                       
  ,TEMPOFALANDO    INT                                                    
  ,TEMPOTABULANDO    INT                                         
  ,TEMPOCHAMADA    INT                                                    
  ,TEMPOESPERA    INT                                
  ,DESLIGADOPOR    INT                                                    
  ,IDPERFIL     INT                                                    
  ,SEGMENTOCANAL    INT                                                    
  ,PORTFOLIO     INT                                                    
  ,PRODUTOPORTFOLIO   INT                                       
  ,CARTEIRA     VARCHAR(50)                                                    
  ,PRODUTO     VARCHAR(50)                                                    
  ,SUBPRODUTO    VARCHAR(50)                                                    
  ,ATRASO      INT                                                    
  ,RATING      VARCHAR(50)                                                    
  ,SCORE      VARCHAR(50)                                                    
  ,SEGURO      INT                                                    
  ,TIPOCHEQUE     INT                                                    
  ,TIPOMANUTENCAOOPER   INT                                                    
  ,IDREMESSA     INT                                      
  ,MAILING     INT                                                    
  ,UF       VARCHAR(2)                                                    
  ,CIDADE      VARCHAR(50)                                                    
  ,LOJA      INT                                        
,LOJISTA     VARCHAR(50)                                                    
  ,DIRETORIAREG    VARCHAR(500)                                                    
  ,GERENCIAREG    VARCHAR(500)                                                    
  ,DATASAFRA     DATE                                                    
  ,FILA       VARCHAR(50)                                                    
  ,VLRPRINC     NUMERIC(15,2)                                                    
  ,VLRATRASO     NUMERIC(15,2)                                                    
  ,PARCELAATRASO    INT                                                    
  ,TIPOCANAL INT                                                  
  ,COLCHAO INT                                                  
  )                                                    
                                                    
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CRMDAC_FINAL ([DATA])                                                    
  CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CRMDAC_FINAL(IDCALL)                                                    
 END                                                    
                                                    
 /***************************************** DROP TABLE SELEÇÕES *******************************************/        
 IF OBJECT_ID ('SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE                                                    
 END      
 
 IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_1_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_1_TESTE                                                    
 END                                                    
                               
 IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE                                                    
 END                                                    
                                                  
 IF OBJECT_ID ('SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE                                                    
 END                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE') IS NOT NULL                           
 BEGIN                                              
  DROP TABLE SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE                                                    
 END                                                   
                             
 IF OBJECT_ID ('SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE                            
 END                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE                                                    
 END                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                   
  DROP TABLE SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE                                                    
 END                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE') IS NOT NULL                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE                                                    
 END                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE') IS NOT NULL                                         
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE                           
 END     
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                            
  DROP TABLE SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE                                                    
 END              
                        
 IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE                                             
 END                                            
                                   
 IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE                                                    
 END                                   
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE') IS NOT NULL           
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE                                                    
 END                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE') IS NOT NULL                   
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE                                                    
 END                                                    
                                                  
 IF OBJECT_ID ('SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 BEGIN                                                    
  DROP TABLE SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE                                                    
 END                                                    
                                                    
 DECLARE @VLR_INI INT = 1, @VLR_FIN INT = 1000, @BLOCO INT = 1000, @ID_LOG INT, @QTD_REGISTROS INT, @QTD_REGISTROS_del int--, @DATA DATETIME  = NULL                                            
 DECLARE @QTD_OLOS INT = 0, @QTD_SINERGY INT = 0                                                  
                                                    
 /***************************************************** DATA **************************************************************/                                                    
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
                                                    
 /****************************************************** SELEÇÕES ***********************************************************/                                      
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO ACIONA')                                       
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
  
 IF OBJECT_ID ('SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE') IS NULL                                                    
 BEGIN                                    
  WITH CTE AS (           
  SELECT                                                     
   A.ID AS ID_ACIONA, A.CONTRATO_FIN, A.DATA_ACIONA, A.COD_RECUP, A.COD_ACIONAMENTO, A.TEL_TEL, A.DDD_TEL,                                                     
   B.DESC_ACIONAMENTO, B.CODACIONADEEPCENTER_ACIONAMENTO, B.DESCRICAODEEPCENTER_ACIONAMENTO, TIPOCANALDEEPCENT_ACIONAMENTO                          
   ,C.ID_ENQUETE, C.ID_RESPOSTA        
   ,row_number() over (partition by A.DATA_ACIONA, A.COD_RECUP, A.COD_ACIONAMENTO, A.TEL_TEL, A.DDD_TEL order by A.ID) as seqnum                                    
   --INTO SRC.DBO.ACIONA_BRADESCO_SELECAO                                                    
  FROM                                                     
   [SRC].DBO.ACIONA  AS A (NOLOCK)                              
   JOIN [SRC].DBO.CAD_ACIONAMENTO AS B (NOLOCK) ON A.COD_ACIONAMENTO = B.COD_ACIONAMENTO           
   LEFT JOIN TBL_RECUP_RESPOSTAS_ENQUETES AS C ON A.ID = C.ID_ACIONA        
  WHERE                                                     
	cast(DATA_ACIONA as date) = '20250429' AND                                                  
    EXISTS (SELECT * FROM [SRC].DBO.CAD_DEVF AS B (NOLOCK) WHERE A.CONTRATO_FIN = B.CONTRATO_FIN AND B.COD_CLI IN (3,11,16,17)           
	 AND B.STATCONT_FIN = 0) --OS171361                                                     
	 --AND NOT EXISTS (SELECT * FROM SRC.DBO.TBL_CONTROLE_DEEPCENTER_CRMDAC AS C WHERE A.ID = C.ID_ACIONA)                                                  
	 AND TIPOCANALDEEPCENT_ACIONAMENTO <> 10  and a.CONTRATO_FIN = '4776653ID'                                   
	 )                                    
 SELECT ID_ACIONA, CONTRATO_FIN, DATA_ACIONA, COD_RECUP, COD_ACIONAMENTO, TEL_TEL, DDD_TEL,                                  
   DESC_ACIONAMENTO, CODACIONADEEPCENTER_ACIONAMENTO, DESCRICAODEEPCENTER_ACIONAMENTO, TIPOCANALDEEPCENT_ACIONAMENTO          
   ,ID_ENQUETE, ID_RESPOSTA        
 INTO SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE                                    
 FROM CTE A                                    
 WHERE SEQNUM = 1                              
 --AND NOT EXISTS (SELECT * FROM SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC AS C WHERE A.ID_ACIONA = C.ID_ACIONA)                                    
                                                  
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
  CREATE NONCLUSTERED INDEX CL_IX ON SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE(ID_ACIONA)                                                    
  CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE(CONTRATO_FIN)                              
  CREATE NONCLUSTERED INDEX NON_IX10_teste ON SRC.DeepCenter.[ACIONA_BRADESCO_SELECAO] ([TEL_TEL])                                                     
  INCLUDE ([ID_ACIONA],[CONTRATO_FIN],[DATA_ACIONA],[COD_RECUP],[COD_ACIONAMENTO])                                                    
 END 

 --select * from SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE
                                                    
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                         
                                                  
 ------------------------------------------------------------------------------------------------------            
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO TAB_IDLIGACAO')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                       
                                                  
 IF OBJECT_ID ('SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE') IS NULL                                        
 BEGIN                                              
                                               
  IF OBJECT_ID ('TEMPDB.dbo.#TEMP_TAB_IDLIGACAODISCADOR_ACIONA') IS NOT NULL                      
  BEGIN                  
  DROP TABLE #TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                                  
  END                                                  
                                                  
 SELECT                                                     
  ID_ACIONA, ID_LIGACAO AS IDCALL, ID_CAMPANHA, CODIGO_CAMPANHA, TIPO_LIGACAO, DISCADOR, CONTRATO_FIN                                                    
  INTO #TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                                  
 FROM                                                     
  [SRC].DBO.TAB_IDLIGACAODISCADOR_ACIONA AS A (NOLOCK)                               WHERE                                                     
  EXISTS (SELECT * FROM SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE AS B WHERE A.ID_ACIONA = B.ID_ACIONA)                                                    
                                                  
 SELECT                                           
  * INTO SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE                                                    
 FROM (                                                  
  SELECT *, ROW_NUMBER() OVER(PARTITION BY IDCALL, CONTRATO_FIN ORDER BY IDCALL) AS RW                                                  
  FROM #TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                                  
 ) AS X                                               
 WHERE RW = 1                                  
 
 --select * from SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE
    --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
 CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE (ID_ACIONA) INCLUDE (IDCALL)                                                    
 CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE(IDCALL)                                                 
 CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE(IDCALL, DISCADOR)                                                  
 END                                              
                                                    
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                                                  
 ------------------------------------------------------------------------------------------------------                     
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO OLOS')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE') IS NULL                                                    
 BEGIN                                           
 SELECT      
   IDCALL,DATA,HORAINICIO,HORAFIM,CPF,CONTRATO,PHONENUMBER,TIPODISCAGEM,TIPOATENDIMENTO,TEMPOFALANDO,TEMPOTABULANDO               
   ,TEMPOCHAMADA,TEMPOESPERA,DESLIGADOPOR, MAILING, IDGRAVACAO                                         
   INTO SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE                                                    
   FROM                     
   SRC.[DEEPCENTER].DISCAGENS_OLOS AS A (NOLOCK)                                                    
  WHERE                                                    
   EXISTS (SELECT * FROM SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE (NOLOCK) AS B WHERE A.IDCALL = B.IDCALL /*AND A.CONTRATO = B.CONTRATO_FIN*/)                                                
   --AND NOT EXISTS (SELECT * FROM SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC AS C WHERE A.IDCALL = C.IDCALL)                                                
   AND TIPODISCAGEM != 4 --OS 166643                                                
                                                  
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
  --SET @QTD_olos = @QTD_REGISTROS                              
                                                    
  CREATE NONCLUSTERED INDEX NON_IX  ON SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE (IDCALL)                                 
  --CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE (CONTRATO)                                                      
 END     
 
 --select * from SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE
                                               
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                           
                                                  
 ------------------------------------------------------------------------------------------------------                                     
                                                  
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO SINERGYTECH')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                                  
 IF OBJECT_ID ('SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE') IS NULL                                                    
 BEGIN                               SELECT                                                   
  CALLRESULTID AS IDCALL_SINERGYTECH, TEMPO_FALADO AS TEMPOFALANDO, TEMPO_DISCAGEM AS TEMPOCHAMADA                                                  
  INTO SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE                                                
 FROM TBL_RESULTADODISCAGEM_SINERGYTECH (NOLOCK) AS A                                                  
 WHERE EXISTS (SELECT * FROM SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE (NOLOCK) AS B WHERE A.CALLRESULTID = B.IDCALL AND B.DISCADOR = 'SINERGYTECH')                                                  
    AND NOT EXISTS (SELECT * FROM SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC AS C WHERE A.CALLRESULTID = C.IDCALL_SINERGYTECH)                                                  
                                                  
 --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
 --SET @QTD_sinergy = @QTD_REGISTROS                                                   
                                                  
 CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE (IDCALL_SINERGYTECH) INCLUDE(TEMPOFALANDO, TEMPOCHAMADA)                                                  
 END;                                                  
 
 --select * from SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE

 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                          
    
 IF (@QTD_SINERGY = 0 AND @QTD_OLOS = 0)                                                  
 BEGIN                                                  
 RETURN                                                  
 END;                                                  
                                                  
 ------------------------------------------------------------------------------------------------------                                            
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO DEVF')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE') IS NULL     
 BEGIN                                                    
  SELECT                                                     
   A.CONTRATO_FIN, A.COD_CLI, A.COD_CAR, A.ATRASO_FIN, A.DTENTRADA_FIN, CAST(A.VALOR_FIN AS NUMERIC(15,2)) AS VALOR_FIN, A.COD_STCB,                                                    
   B.CPF_DEV, B.NOME_DEV, B.COD_TIPESS, B.COD_UF,                                         
   C.PORTFOLIODEEPCENTER_CLI, D.PRODPORTFOLIODEEPCENTER_CAR                                
   ,B.EMAIL_DEV                                
   ,A.PLANO_FIN                                
   INTO SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE                                          
  FROM                                                     
   [SRC].dbo.CAD_DEVF AS A (NOLOCK)                                                    
   JOIN [SRC].dbo.CAD_DEV AS B (NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                                    
   JOIN [SRC].dbo.CAD_CLI AS C (NOLOCK) ON A.COD_CLI = C.COD_CLI                                                  
   JOIN [SRC].dbo.CAD_CAR_AUX_AUX AS D (NOLOCK) ON A.COD_CLI = D.COD_CLI AND A.COD_CAR = D.COD_CAR                                                   
  WHERE                                                     
   EXISTS (SELECT * FROM SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                    
   AND A.COD_CLI IN (3,11,16,17) --) OR (A.COD_CLI = 16 AND B.COD_TIPESS = 1))                                    
                                                   
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE (CONTRATO_FIN)                                                    
  INCLUDE(CPF_DEV, COD_CLI, COD_CAR, ATRASO_FIN, DTENTRADA_FIN, VALOR_FIN )                                                    
                                          
  CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE (CPF_DEV)                                                    
  INCLUDE(CONTRATO_FIN, COD_CLI, COD_CAR, ATRASO_FIN, DTENTRADA_FIN, VALOR_FIN )                                                    
                                                    
  CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE (CONTRATO_FIN)                                                    
  CREATE NONCLUSTERED INDEX NON_IX3 ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE (CPF_DEV)                                                    
 END      
 
 --select * from SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE
                                                    
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                                  
 ------------------------------------------------------------------------------------------------------     
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO AUX_DEVF')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE') IS NULL                                     
 BEGIN                                                    
  SELECT                                                     
   CONTRATO_FIN, CONTRATO_ORIGINAL                                                    
   INTO SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE                                                    
  FROM                                                    
   [SRC].DBO.AUX_DEVF AS A  (NOLOCK)                                                    
  WHERE                                                     
   EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                        
                                          
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE (CONTRATO_FIN) INCLUDE (CONTRATO_ORIGINAL)                                                    
 END                                                    
 
 --select * from SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE

 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                                                
 ------------------------------------------------------------------------------------------------------                                                  
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO DEVP')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()
 
 IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE') IS NULL                                                    
 BEGIN                                                    
  SELECT                                                     
  CONTRATO_FIN                 
   ,CAST(VALOR_ACOP AS NUMERIC(15,2)) AS VALOR_ACOP                                                   
   ,PARCELA_ACOP                                
   ,TIPO_PARCACO                                                    
   INTO SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE                                                    
  FROM                                                     
   [SRC].DBO.CAD_ACOP AS A (NOLOCK)                                                    
  WHERE                                        
   EXISTS ( SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                                    
   AND COD_STPA = 0 AND CAST(VENC_ACOP AS DATE) < '20250429'                                    
                                   
                                   
                                                    
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                     
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE (CONTRATO_FIN, PARCELA_ACOP, TIPO_PARCACO)                                                    
  INCLUDE (VALOR_ACOP)                                      
                                       
  CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE (CONTRATO_FIN, VALOR_ACOP)                                         
 END   
 
 --select * from SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE  
 
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG              
                                                  
 ------------------------------------------------------------------------------------------------------                                                  
                                               
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','DEVP AGREGAÇÃO')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE') IS NULL                                                    
 BEGIN                                        
  SELECT                                                     
   CONTRATO_FIN                                                    
   ,SUM(VALOR_ACOP) AS VLRATRASO                    
   ,COUNT(*) AS PARCELAATRASO                                  
   INTO SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE                                                    
  FROM                                                     
   SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE AS A (NOLOCK)                                                    
  GROUP BY CONTRATO_FIN                                     
                                  
  --select * from cad_acop                                
                                
  --select * from cad_stpa                                
                                                  
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE (CONTRATO_FIN)                                                    
  INCLUDE (VLRATRASO, PARCELAATRASO)                                                   
 END                                                 
 
 --select * from SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE  

 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                                                  
 ------------------------------------------------------------------------------------------------------                                                  
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO DEVT')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                                     
 IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE') IS NULL                                           
 BEGIN                     
 SELECT CPF_DEV, DDD_TEL, TEL_TEL, PERC_TEL, POSSUIWHATSAPP_TEL, COD_TEL                                                  
   INTO SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE                                          
  FROM                                                     
   [SRC].DBO.CAD_DEVT  AS A  (NOLOCK)                                                    
  WHERE                                                     
   EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS B WHERE A.CPF_DEV = B.CPF_DEV)                                                    
   AND PERC_TEL > 0                                                  
         
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE (CPF_DEV, DDD_TEL, TEL_TEL)                                                    
  CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE (CPF_DEV) INCLUDE (DDD_TEL, TEL_TEL, PERC_TEL, POSSUIWHATSAPP_TEL, COD_TEL)                                                    
                                                    
 END                                                    
 
 --select * from SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE

 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                                                  
 ------------------------------------------------------------------------------------------------------                            
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO DEVE')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                                       
 IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE') IS NULL                                                    
 BEGIN                                                    
  SELECT CPF_DEV, CIDADE_END, COD_UF, PERC_END, DTINCLUSAO_END, COD_END --CASE WHEN COD_TIPO > 2 THEN 9 ELSE COD_TIPO END AS ORDEM                                                
   INTO SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE                                                    
  FROM                                                     
   [SRC].DBO.CAD_DEVE AS A (NOLOCK)                                                    
  WHERE                                        
   EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS B WHERE A.CPF_DEV = B.CPF_DEV)                                                    
                                                      
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                     
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE (CPF_DEV) INCLUDE (CIDADE_END, COD_UF, PERC_END, DTINCLUSAO_END/*, ORDEM*/)                                                  
  CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE (CPF_DEV, COD_UF) INCLUDE(CIDADE_END, PERC_END, DTINCLUSAO_END/*, ORDEM*/)                                                  
 END
 
 --select * from SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE
                                                    
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                         
 ------------------------------------------------------------------------------------------------------                                                  
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO AUX_BRADESCOBANCO')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                       
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE') IS NULL                                                    
 BEGIN                                        
  SELECT CONTRATO_FIN, CARTEIRA, CASE WHEN NOMEPRODUTO = '' THEN NULL ELSE NOMEPRODUTO END AS NOMEPRODUTO, 2 AS FLAG, A.COD_EMPRESA                                                  
   INTO SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE     
  FROM                              
   [SRC].dbo.AUX_BRADESCOBANCO AS A  (NOLOCK)                         
   LEFT JOIN [SRC].dbo.BRADESCOPRODUTOS AS B ON (B.CODPRODUTO = A.CARTEIRA)                                                       
  WHERE                                   
EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS C WHERE A.CONTRATO_FIN = C.CONTRATO_FIN)                                
                                                    
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE (CONTRATO_FIN) INCLUDE(CARTEIRA, NOMEPRODUTO, FLAG)                                                    
 END                                       
 
 --select * from SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE

 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
                                          
------------------------------------------------------------------------------------------------------                                                  
                                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO AUX_BRADESCOLPTITULO')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                               
                                                    
 IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE') IS NULL                            
 BEGIN                                           
 SELECT                                          
  CONTRATO_FIN, CARTEIRA AS CARTEIRA, COD_NATUREZA AS PRODUTO, DESC_NATUREZA AS SUBPRODUTO, TITULO, AGENCIA, CONTA,                                          
  AGENCIA_CLIENTE, CONTA_CLIENTE, TRY_CONVERT(VARCHAR,NUMERO_CARTEIRA) AS NUMERO_CARTEIRA                                        
  INTO SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE                                          
 FROM                                          
  [SRC].DBO.AUX_BRADESCOLPTITULO AS A WITH(NOLOCK)                                          
 WHERE                                          
  EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                                
                                       
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
                                                    
  --CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE (CONTRATO_FIN) INCLUDE(CARTEIRA, NOMEPRODUTO, FLAG)                                                    
 END                                                    
 
 --select * from SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE

 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                       
                                                
                                                    
 /****************************************************** JUNÇÃO ACIONA / DISCADOR ***********************************************************/                                                      
                                                  
 SELECT *                                              
  INTO SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE                                                    
 FROM (                                                  
              
  SELECT                                                   
 A.*, B.IDCALL, B.PHONENUMBER, --IIF(B.TIPODISCAGEM=2,1,B.TIPODISCAGEM) AS TIPODISCAGEM, - -retirado na OS 156136    
 CASE                                                  
  --WHEN C.TIPO_LIGACAO = 2 THEN 4 -- ACRESCENTADO NA OS 156136                                                  
  WHEN C.TIPO_LIGACAO = 2 THEN 5 --ACRESCENTADO NA OS 156650                                                  
  WHEN B.TIPODISCAGEM=2 THEN 1                                                  
  ELSE                                                   
   B.TIPODISCAGEM                                                  
  END                                                   
  AS TIPODISCAGEM,                                                   
 B.TIPOATENDIMENTO,B.TEMPOFALANDO, B.IDGRAVACAO, B.HORAINICIO, B.HORAFIM,                                                  
 B.TEMPOTABULANDO,B.TEMPOCHAMADA,B.TEMPOESPERA, B.DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, C.TIPO_LIGACAO,                         
 LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA /*B.HORA*/, NULL AS IDCALL_SINERGYTECH, B.MAILING         
  FROM SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE AS A (NOLOCK)                                                    
  JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE AS C (NOLOCK) ON C.ID_ACIONA = A.ID_ACIONA                                                    
  JOIN SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE AS B (NOLOCK) ON B.IDCALL = C.IDCALL /*AND B.CONTRATO = A.CONTRATO_FIN*/                                                  
  --AND CAST(A.DATA_ACIONA AS DATE) = B.[DATA] AND B.PHONENUMBER = RTRIM(LTRIM(A.DDD_TEL)) + RTRIM(LTRIM(A.TEL_TEL))                                                  
  WHERE A.TIPOCANALDEEPCENT_ACIONAMENTO NOT IN (4,10)                                                  
                                                    
  UNION ALL                                                  
                              
  SELECT A.*, A.ID_ACIONA AS IDCALL, COALESCE(A.DDD_TEL,'')+COALESCE(A.TEL_TEL,'') AS PHONENUMBER, 2 AS TIPODISCAGEM, 1 AS TIPOATENDIMENTO, NULL AS TEMPOFALANDO,                                 
  NULL AS IDGRAVACAO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAINICIO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAFIM,                                                   
  NULL AS TEMPOTABULANDO, NULL AS TEMPOCHAMADA, NULL AS TEMPOESPERA, NULL AS DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, C.TIPO_LIGACAO,                                                   
  LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA, NULL AS IDCALL_SINERGYTECH, NULL AS MAILING          
  FROM SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE AS A (NOLOCK)                                                  
  LEFT JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE AS C (NOLOCK) ON C.ID_ACIONA = A.ID_ACIONA                                            
  WHERE A.TIPOCANALDEEPCENT_ACIONAMENTO = 4                                                  
                                                  
  UNION ALL                                                   
                                                  
  SELECT                                                   
   A.*, A.ID_ACIONA AS IDCALL, B.PHONENUMBER, 4 AS TIPODISCAGEM, 1 AS TIPOATENDIMENTO, NULL AS TEMPOFALANDO,                                 
   NULL AS IDGRAVACAO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAINICIO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAFIM,                                              
   NULL AS TEMPOTABULANDO, NULL AS TEMPOCHAMADA, NULL AS TEMPOESPERA, NULL AS DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, D.TIPO_LIGACAO,                                                   
   LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA, NULL AS IDCALL_SINERGYTECH, NULL AS MAILING              
  FROM                                                   
 SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE AS A (NOLOCK)                                                  
 JOIN SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS C (NOLOCK) ON C.CONTRATO_FIN = A.CONTRATO_FIN                
 CROSS APPLY (SELECT TOP 1 RTRIM(LTRIM(B.DDD_TEL))+RTRIM(LTRIM(B.TEL_TEL)) AS PHONENUMBER                                                  
     FROM SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE AS B (NOLOCK)                                                    
     WHERE B.CPF_DEV = C.CPF_DEV AND LEN(B.TEL_TEL)>=9                                                  
     ORDER BY B.POSSUIWHATSAPP_TEL, B.PERC_TEL DESC, B.COD_TEL DESC) AS B                                                  
 LEFT JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE AS D (NOLOCK) ON D.ID_ACIONA = A.ID_ACIONA  AND TIPO_LIGACAO = 2 /*AND TIPO_LIGACAO = 2 ACRESCENTADO NA OS 156136*/                                   
  WHERE                                                   
 A.TIPOCANALDEEPCENT_ACIONAMENTO = 10                                                  
                                                  
  UNION ALL                                                    
                                   
  SELECT                                                   
   A.*, B.IDCALL_SINERGYTECH AS IDCALL, COALESCE(A.DDD_TEL,'')+COALESCE(A.TEL_TEL,'') AS PHONENUMBER, 2 AS TIPODISCAGEM, 1 AS TIPOATENDIMENTO, B.TEMPOFALANDO,                                                   
   NULL AS IDGRAVACAO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAINICIO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAFIM,                              
   NULL AS TEMPOTABULANDO, B.TEMPOCHAMADA,                    
 NULL AS TEMPOESPERA, NULL AS DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, C.TIPO_LIGACAO,                             
   LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA, B.IDCALL_SINERGYTECH, NULL AS MAILING               
  FROM                 
 SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE AS A (NOLOCK)                                                  
 JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE AS C (NOLOCK) ON C.ID_ACIONA = A.ID_ACIONA                                                    
 JOIN SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE AS B (NOLOCK) ON C.IDCALL = B.IDCALL_SINERGYTECH                                               
                                              
 ) AS X 
 
 --select * from SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE
                                                    
                                                    
 /****************************************************** JUNÇÃO ***********************************************************/                                                    
                                                    
 DECLARE @IDREMESSA INT = NULL                         
 EXEC STPGERAIDREMESSADEEPCENTERNEW 'CRMDAC', 'DBO', @IDREMESSA OUTPUT                                  
 --PRINT @IDREMESSA                                                  
                              
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','SELEÇÃO TBL_JUNCAO_BRADESCO_CRMDAC')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                                    
                    --DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE') IS NULL                                                    
 BEGIN                                                 
                            
  SELECT ROW_NUMBER() OVER(ORDER BY [DATA], HORA) AS ID,*                               
   INTO SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE                                                   
  FROM (           
   SELECT                                                     
    ROW_NUMBER () OVER (PARTITION BY A.ID_ACIONA ORDER BY A.ID_ACIONA) AS RW          
    ,A.IDCALL AS IDCALL                                                    
    ,TRY_CONVERT(DATE, A.DATA_ACIONA) AS [DATA]                                                  
    ,A.HORA                                                    
                                                        
    ,CASE                                                    
  WHEN G.NOME_RECUP = 'DISCADOR' THEN 'TENTATIVA DISCAGEM – MAQUINA'                                                   
  ELSE G.NOME_RECUP                                                    
 END AS AGENTE                                                    
                                                  
     ,CASE   
      WHEN G.NOME_RECUP IN ('OLOS','OLOS WAY') THEN 'DISCADOR'                                                    
      ELSE CAST(G.COD_RECUP AS VARCHAR(10))                                                    
      END AS idAgent                                                    
                                     
    ,CASE WHEN COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(E.CPF_DEV)), 14)                                         
     ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(E.CPF_DEV)), 11) END AS IDCUSTOMER                                                    
                                                    
  ,CASE                                                     
     WHEN COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0) = 1 THEN ''                                                    
     ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(E.CPF_DEV)), 11)                                                     
 END AS CPF                                        
                                   ,CASE                
     WHEN COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(E.CPF_DEV)), 14)                                                     
     ELSE ''                                                    
    END AS CNPJ                                                    
                                                        
    ,CASE                           
  WHEN E.COD_CLI IN (16,17) THEN COALESCE(K.TITULO, F.CONTRATO_ORIGINAL)                 
     WHEN F.CONTRATO_ORIGINAL IS NOT NULL THEN F.CONTRATO_ORIGINAL                                                    
     WHEN CHARINDEX('-', E.CONTRATO_FIN) > 1 THEN LEFT(E.CONTRATO_FIN, CHARINDEX('-', E.CONTRATO_FIN)-1)                                                    
 ELSE E.CONTRATO_FIN                                                    
    END AS CONTRATO                             
                                                  
 --,COALESCE(TRY_CAST(A.CODACIONADEEPCENTER_ACIONAMENTO AS INT), A.COD_ACIONAMENTO) AS IDOCORRENCIA                                         
    --,COALESCE(IIF(RTRIM(LTRIM(A.DESCRICAODEEPCENTER_ACIONAMENTO))='',NULL,A.DESCRICAODEEPCENTER_ACIONAMENTO), A.DESC_ACIONAMENTO) AS DESCOCORRENCIA,                                                    
                                                      
 --,IIF(A.CODACIONADEEPCENTER_ACIONAMENTO = 8202, IIF(A.TEMPOESPERA <= 15, 4999, 4998),COALESCE(TRY_CAST(A.CODACIONADEEPCENTER_ACIONAMENTO AS INT), A.COD_ACIONAMENTO)) AS IDOCORRENCIA                                                
    ,A.COD_ACIONAMENTO AS IDOCORRENCIA                             
 ,IIF(A.CODACIONADEEPCENTER_ACIONAMENTO = 8202, IIF(A.TEMPOESPERA <= 15, 'NAO OUVIU RECADO HANG UP', 'VOICER HANG UP'),COALESCE(IIF(RTRIM(LTRIM(A.DESCRICAODEEPCENTER_ACIONAMENTO))='',           
                                       
 NULL,A.DESCRICAODEEPCENTER_ACIONAMENTO), A.DESC_ACIONAMENTO)) AS DESCOCORRENCIA ,                                                  
                                                    
                                
                                                     
    COALESCE(IIF(A.PHONENUMBER='0',NULL,A.PHONENUMBER), I.PHONENUMBER) AS PHONENUMBER                                                    
                                                    
 --,IIF(A.TIPOCANAL= 4, 2, A.TIPODISCAGEM) AS TIPODISCAGEM                                                   
 --   ,IIF(A.TIPOCANAL= 4, 1, A.TIPOATENDIMENTO) AS TIPOATENDIMENTO                                                  
                                                   
 ,IIF(G.NOME_RECUP = 'OLOS WAY', 2, A.TIPODISCAGEM) AS TIPODISCAGEM                                          
 ,IIF(G.NOME_RECUP = 'OLOS WAY', 1, A.TIPOATENDIMENTO) AS TIPOATENDIMENTO                                                  
                                                  
    ,0 AS ORIGEMTEL                                                    
    ,A.TEMPOFALANDO                                                    
    ,A.TEMPOTABULANDO                                                    
    ,A.TEMPOCHAMADA                         
    ,A.TEMPOESPERA                                                    
    --,CASE WHEN G.COD_RECUP = 1071 THEN 2 ELSE A.DESLIGADOPOR END AS DESLIGADOPOR                                                    
    ,A.DESLIGADOPOR                                                     
                                                    
    ,CASE                     
     WHEN COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0) >= 2 THEN 0                                                     
     ELSE COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0)                                                     
    END AS IDPERFIL                                                    
                                      
    ,3 AS SEGMENTOCANAL                                                  
                                            
 --,IIF(L.COD_EMPRESA = 'ABLG0000', 6, IIF(R.CPF_DEV IS NOT NULL, 21,                        
 --IIF(E.COD_CLI = 3, E.PORTFOLIODEEPCENTER_CLI,                                                   
 --IIF(E.COD_CLI = 11,                                                  
 -- CASE                                                  
 --  WHEN SUBSTRING(X.FILLER, 3, 5) = '3A52' THEN 22                                                  
 --  WHEN SUBSTRING(X.FILLER, 3, 5) = '2A52' THEN 23                                                  
 --  WHEN SUBSTRING(X.FILLER, 3, 5) = '4A53' THEN 24                            
 --  WHEN SUBSTRING(X.FILLER, 3, 5) = '7A51' THEN 25                                
 --  WHEN SUBSTRING(X.FILLER, 3, 5) = '8A51' THEN 26                                                  
 --  WHEN SUBSTRING(X.FILLER, 3, 5) NOT IN ('3A52','2A52','4A53','7A51','8A51') THEN 27             
 --  WHEN X.FILLER IS NULL     THEN 27                                                  
 --  ELSE 27                                                  
 -- END,                                                  
 -- IIF(R.CPF_DEV IS NULL, E.PORTFOLIODEEPCENTER_CLI, 21))                                                  
 --))) AS PORTFOLIO                                                  
                                                  
 ,CASE                              
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '3A52' THEN 6 -- OS168675                                          
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '2A52' THEN 23                                                  
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '4A53' THEN 24                                                  
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '7A51' THEN 25                                                  
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '8A51' THEN 26                                            
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '6A51' THEN 40 -- OS167390                                   
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '1A52' THEN 41 -- OS167390                                            
  WHEN E.COD_CLI = 11             THEN 27                                 
  WHEN L.COD_EMPRESA = 'ABLG0000'          THEN 6                                                  
  WHEN R.CPF_DEV IS NOT NULL           THEN 6                                                  
  ELSE E.PORTFOLIODEEPCENTER_CLI                 
 END AS PORTFOLIO                                                  
                                                  
 ,CASE                                                  
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '3A52' THEN 39                                                  
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '2A52' THEN 40                                                  
  --WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '4A53' THEN 41                                                  
  WHEN E.COD_CLI = 11 AND COALESCE(E.COD_TIPESS,0) = 0 AND SUBSTRING(ltrim(X.FILLER), 3, 3) = 'A53'  THEN 1019 -- OS170702                                      
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '7A51' THEN 42                                                  
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '8A51' THEN 43                                            
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '6A51' THEN 52 -- OS167390                                            
  WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '1A52' THEN 53 -- OS167390                                            
  WHEN E.COD_CLI = 11             THEN 44                             
  WHEN L.COD_EMPRESA = 'ABLG0000'         THEN 1             
  WHEN R.CPF_DEV IS NOT NULL           THEN 1 -- OS168675                                                  
  ELSE E.PRODPORTFOLIODEEPCENTER_CAR                                  
 END AS PRODUTOPORTFOLIO                                                  
                        
 --,IIF(E.PORTFOLIODEEPCENTER_CLI = 7, 'EAVM', SUBSTRING(L.CARTEIRA,PATINDEX('%[A-Z,1-9]%',L.CARTEIRA),LEN(L.CARTEIRA))) AS CARTEIRA                                                         
 ,CASE                                          
 WHEN E.COD_CLI IN (16,17) THEN SUBSTRING(K.CARTEIRA,PATINDEX('%[a-z,1-9]%',K.CARTEIRA),LEN(K.CARTEIRA ))                                          
 WHEN E.PORTFOLIODEEPCENTER_CLI = 7 THEN 'EAVM'                                          
 ELSE SUBSTRING(L.CARTEIRA,PATINDEX('%[A-Z,1-9]%',L.CARTEIRA),LEN(L.CARTEIRA))                                          
  END AS CARTEIRA                                          
                                          
 --,IIF(E.PORTFOLIODEEPCENTER_CLI = 7, J.DESCRIAO, L.NOMEPRODUTO) AS PRODUTO                                                    
 ,CASE                                          
 WHEN E.COD_CLI IN (16,17) THEN K.SUBPRODUTO                                          
 WHEN E.PORTFOLIODEEPCENTER_CLI = 7 THEN  J.DESCRIAO                    
 ELSE  L.NOMEPRODUTO                                          
  END AS PRODUTO                                        
             
 ,IIF(E.PORTFOLIODEEPCENTER_CLI = 7, J.DESCRIAO, NULL) AS SUBPRODUTO                                                    
                                                    
    ,E.ATRASO_FIN AS ATRASO                                                   
                                                
    ,CASE                                     
     WHEN E.ATRASO_FIN BETWEEN 60 AND 90  THEN 'FASE 1'                          
     WHEN E.ATRASO_FIN BETWEEN 91 AND 120 THEN 'FASE 2'                                                    
     WHEN E.ATRASO_FIN BETWEEN 121 AND 150 THEN 'FASE 3'                                                   
     WHEN E.ATRASO_FIN BETWEEN 151 AND 180 THEN 'FASE 4'                                                    
     WHEN E.ATRASO_FIN BETWEEN 181 AND 360 THEN 'FASE 5'                                                  
     WHEN E.ATRASO_FIN BETWEEN 361 AND 720 THEN 'FASE 6'                                                    
     WHEN E.ATRASO_FIN BETWEEN 721 AND 1080 THEN 'FASE 7'                                                    
     WHEN E.ATRASO_FIN BETWEEN 1081 AND 1440 THEN 'FASE 8'                                                    
     WHEN E.ATRASO_FIN BETWEEN 1441 AND 1800 THEN 'FASE 9'                                                    
     WHEN E.ATRASO_FIN BETWEEN 1801 AND 2160 THEN 'FASE 10'                        
     WHEN E.ATRASO_FIN BETWEEN 2160 AND 2520 THEN 'FASE 11'         
     WHEN E.ATRASO_FIN BETWEEN 2521 AND 2880 THEN 'FASE 12'                                                    
     WHEN E.ATRASO_FIN BETWEEN 2881 AND 3240 THEN 'FASE 13'                            
     WHEN E.ATRASO_FIN BETWEEN 3241 AND 3600 THEN 'FASE 14'                                                    
     WHEN E.ATRASO_FIN > 3600    THEN 'FASE 15'                                                    
    END AS RATING                                                    
                                                    
    ,NULL AS SCORE                                                    
    ,NULL AS SEGURO                                                 
  ,NULL AS TIPOCHEQUE                                               
    ,NULL AS TIPOMANUTENCAOOPER                                                    
    --,@IDREMESSA AS IDREMESSA                                                    
    ,NULL AS IDREMESSA                                                   
    ,A.MAILING                                                    
 ,Q.DESC_UF AS UF                                                  
 ,P.CIDADE_END AS CIDADE                                                    
    ,NULL AS LOJA                                                    
 ,NULL AS LOJISTA                                                    
    ,NULL AS DIRETORIAREG                                                    
    ,NULL AS GERENCIAREG              
    ,CAST(E.DTENTRADA_FIN AS DATE) AS DATASAFRA                                                    
    ,IIF(E.COD_CLI IN (16,17), COALESCE(CAST(K.NUMERO_CARTEIRA AS VARCHAR), CAST(K.CARTEIRA AS VARCHAR)), CAST(E.COD_STCB AS VARCHAR)) AS FILA                                                     
    ,E.VALOR_FIN AS VLRPRINC                                                    
    ,H.VLRATRASO AS VLRATRASO                                                    
 ,H.PARCELAATRASO AS PARCELAATRASO                                                    
                              
 -- SOLICITAÇÃO NA OS 164771                                                  
 ,CASE                                                   
  WHEN G.NOME_RECUP = 'OLOS WAY' THEN 4                                                  
  WHEN A.TIPOATENDIMENTO = 1 THEN 4                                                  
  WHEN A.TIPOCANAL = 4 THEN 4                                                  
  WHEN A.TIPOCANAL = 10 THEN 10                                                  
  ELSE NULL                                                  
 END AS TIPOCANAL                                                  
                                                  
 ,A.ID_ACIONA                                                  
 ,A.IDCALL_SINERGYTECH                                        
 ,A.IDGRAVACAO                                
 ,A.HORAINICIO          
 ,A.HORAFIM                                
 ,CASE                                     
  WHEN E.COD_STCB IN (16,125,126) THEN 1                                 
  ELSE 0                                                  
 END AS COLCHAO,                                
 E.EMAIL_DEV AS EMAIL,                                
 E.PLANO_FIN AS PLANO         
 ,A.ID_ENQUETE, A.ID_RESPOSTA
   FROM                              
    SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE AS A (NOLOCK)                                                    
    JOIN SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE AS E (NOLOCK) ON E.CONTRATO_FIN = A.CONTRATO_FIN                                                    
    LEFT JOIN SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE AS F (NOLOCK) ON F.CONTRATO_FIN = E.CONTRATO_FIN                                                    
    JOIN [SRC].DBO.CAD_RECUP AS G (NOLOCK) ON G.COD_RECUP = A.COD_RECUP                                                    
    LEFT JOIN SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE AS H (NOLOCK) ON H.CONTRATO_FIN = E.CONTRATO_FIN                                                        
                                                    
    OUTER APPLY (SELECT RTRIM(LTRIM(I.DDD_TEL))+RTRIM(LTRIM(I.TEL_TEL)) AS PHONENUMBER                                                  
     FROM SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE AS I (NOLOCK)                               
     WHERE  (I.CPF_DEV = E.CPF_DEV AND I.TEL_TEL = A.TEL_TEL) ) AS I                                                        
                                                    
    LEFT JOIN SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE AS L (NOLOCK) ON L.CONTRATO_FIN = E.CONTRATO_FIN                                                    
                                                      
 --OUTER APPLY( SELECT TOP 1 CIDADE_END FROM SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE AS P                                                     
 --    WHERE P.CPF_DEV = E.CPF_DEV ORDER BY P.ORDEM, P.DTINCLUSAO_END DESC, P.PERC_END DESC ) AS P                                                    
 OUTER APPLY( SELECT TOP 1 COD_UF, CIDADE_END FROM SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE AS P                                                     
     WHERE P.CPF_DEV = E.CPF_DEV ORDER BY P.DTINCLUSAO_END, P.COD_END ) AS P                                                         
                                                    
    --OUTER APPLY ( SELECT TOP 1 UF FROM TBL_TELEFONE_UF AS Q WHERE Q.DDD = COALESCE(LEFT(A.PHONENUMBER,2),RTRIM(LTRIM(I.DDD_TEL))) ) AS Q     
 LEFT JOIN [SRC].dbo.CAD_UF AS Q ON Q.COD_UF = P.COD_UF                                                  
 LEFT JOIN TBL_BRADESCO_PORTOLIO_35 AS R WITH (NOLOCK) ON R.CPF_DEV = E.CPF_DEV                                                   
                            
   OUTER APPLY (SELECT TOP 1 DESCRIAO FROM AUX_CARTOESBRADESCO (NOLOCK) AS J WHERE J.CONTRATO_FIN = A.CONTRATO_FIN) AS J                                                  
                                          
   OUTER APPLY (SELECT TOP 1 * FROM SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE (NOLOCK) AS K WHERE K.CONTRATO_FIN = A.CONTRATO_FIN) AS K                                          
                                                  
   LEFT JOIN AUX_CARTOESBRADESCO AS X WITH(NOLOCK) ON A.CONTRATO_FIN = X.CONTRATO_FIN                                                  
                                                    
   ) AS A WHERE RW = 1                                             
   --OS 169641 - AND UF NOT IN ('RS') -- OS167522 - Retirar RS                                            
                                                    
  --SET @QTD_REGISTROS = @@ROWCOUNT                                                    
 END                                                    
                                
 CREATE CLUSTERED INDEX CL_IX ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE (IDCALL, IDOCORRENCIA)                                
 
 --SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE

 ;WITH CTE AS                                  
 (                                  
 SELECT 
	A.*, B.COD_RESULTADO AS CODACIONAMENTO_DEEP, B.COD_OCORRENCIA--, B.COD_CANALACIONAMENTO
	,C.COD_TIPODISCAGEMDEEPCENTER -- OS 171535
	,ROW_NUMBER () OVER (PARTITION BY A.IDCALL ORDER BY A.IDCALL) AS RW2    
	,0 AS IDMOTIVOINAD -- OS 171112    

	,COALESCE(COD_TIPODISCAGEMDEEPCENTER,COD_CANALACIONAMENTO,1) as COD_CANALACIONAMENTO

	--,CASE  -- OS 171742		
	--	WHEN C.COD_TIPODISCAGEMDEEPCENTER in (1,9) then 0		
	--	WHEN B.COD_CANALACIONAMENTO in (1,9) then 0
	--	WHEN B.COD_CANALACIONAMENTO = 17 and A.TIPOATENDIMENTO = 0 then 0
	--	WHEN COALESCE(C.COD_TIPODISCAGEMDEEPCENTER,B.COD_CANALACIONAMENTO,1) = 1 THEN 0
	--	ELSE 1
	--END AS idOrigemAtendimento
    ,1 AS idOrigemAtendimento
 FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE A                                
 LEFT JOIN [DEEPCENTER].CONFIG_ACIONAMENTO B ON A.IDOCORRENCIA = B.COD_ACIONAMENTO    
 LEFT JOIN DEEPCENTER.CONFIG_TIPODISCAGEM C ON C.COD_TIPODISCAGEMDISCADOR = A.TIPODISCAGEM
 )                                  
 SELECT *                                  
 INTO SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE                                  
 FROM CTE                                  
 WHERE RW2 = 1                               
 
 
 --select * from SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TEST                              
                                
 --DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE                                
                                
 --SELECT * FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE                                
                                  
 --SET @QTD_REGISTROS = @@ROWCOUNT                        
                                                    
 --ALTER TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE ADD ID INT IDENTITY(1,1)                                                     
                                                    
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                              
              
 CREATE CLUSTERED INDEX CL_IX ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE (ID) -- OS167056                                           
                                           
 CREATE NONCLUSTERED INDEX NO_IX_IDCALL ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE(IDCALL) -- OS168731                                          
                                              
 CREATE NONCLUSTERED INDEX NO_IX ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE(IDOCORRENCIA, AGENTE) -- OS167056                 
                 
 CREATE NONCLUSTERED INDEX NO_IX_CANALACIONAMENTO_IDCALL ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE(COD_CANALACIONAMENTO, TIPOATENDIMENTO)                
                 
 UPDATE A SET COD_CANALACIONAMENTO = 1                
 FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE A                
 --JOIN SRC.DeepCenter.DISCAGENS_OLOS B ON A.DSIDCALL = B.IDCALL                
 WHERE A.TIPOATENDIMENTO = 0                
 AND A.COD_CANALACIONAMENTO = 17              
         
 --OS 171112        
 UPDATE B SET IDMOTIVOINAD = A.COD_EXTERNO        
 FROM TBL_RESPOSTAS_ENQUETES A        
 JOIN DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE AS B ON A.ID_ENQUETE = B.ID_ENQUETE AND A.ID_RESPOSTA = B.ID_RESPOSTA        
 WHERE A.COD_EXTERNO <> 0        
                                    
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_new','delete IDOCORRENCIA = 2000016 e AGENTE = OLOS')                                                    
 SET @ID_LOG = SCOPE_IDENTITY()                                       
                                              
 DELETE FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE WHERE IDOCORRENCIA = 2000016 AND AGENTE = 'OLOS' -- OS167056                                  

 UPDATE A SET 
	idOrigemAtendimento = 0
 FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE A                
 where COD_CANALACIONAMENTO in (1,9)

 --UPDATE A SET 
	--idOrigemAtendimento = 1
 --FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE A                
 --where COD_CANALACIONAMENTO not in (1,9)
                                 
                                
 set @QTD_REGISTROS_del = @@ROWCOUNT                                          
                                     
 UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS_del, DATA_FIN = GETDATE() WHERE ID = @ID_LOG      
                                    
 --set @QTD_REGISTROS = @QTD_REGISTROS - @QTD_REGISTROS_del                                    
      
 INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_NEW','INSERT TABELA FINAL')
 SET @ID_LOG = SCOPE_IDENTITY()                            
                                
 --select * from [DEEPCENTER].CONFIG_ACIONAMENTO                                
                                                 
 --select * from SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE                                
                                                    
 --DECLARE @VLR_INI INT = 1, @VLR_FIN INT = 1000, @BLOCO INT = 1000            
 SET @VLR_INI = 1                                       
 SET @VLR_FIN = @BLOCO                                                    
                                                                                               
  INSERT [DeepCenter].[FINAL_ACIONAMENTO](                                                    
	DSNOMEASSESSORIA,
	DTDATAINSERCAO,
	DTDATAREFERENCIA,
	HRHORAINICIO,
	HRHORAFIM,
	NUMTEMPOFALADO,
	NUMTEMPOESPERA,
	DSIDAGENT,
	DSNOMEAGENT,
	NUMTELEFONE,
	NUMCONTRACT,
	NUMCUSTOMER,
	NUMCLIENTE,
	NUMSEGMENTO,
	IDORIGEMTELEFONE,
	IDTIPODISCAGEM,
	IDORIGEMATENDIMENTO,
	IDCANALACIONAMENTO,
	DSEMAIL,
	DSIDCALL,                                
    IDDESLIGADOPOR,
	IDRESULTADO,
	IDOCORRENCIA,
	IDMOTIVOINAD,
	VLRACORDO,
	NUMPLANO,
	IDGRAVACAO,
	DSFRASE,
	NUMPARCELA                                
   )                                                    
  SELECT                                                       
  'MLGomes',
  GETDATE(),
  DATA,
  HORAINICIO,
  HORAFIM,
  TEMPOFALANDO,
  TEMPOESPERA,
  LEFT(IDAGENT,50),
  LEFT(AGENTE,100),
  LEFT(PHONENUMBER,11),
  LEFT(CONTRATO,100),
  IDCUSTOMER,
  LEFT(IDCUSTOMER,14),
  3,
  1,
  TIPODISCAGEM,
  /*TIPOATENDIMENTO*/idOrigemAtendimento,
  COD_CANALACIONAMENTO/*COALESCE(COD_TIPODISCAGEMDEEPCENTER,COD_CANALACIONAMENTO,1)*/,
  NULL,
  LEFT(IDCALL,100),
  DESLIGADOPOR,
  COALESCE(CODACIONAMENTO_DEEP,COD_OCORRENCIA,IDOCORRENCIA),
  COALESCE(COD_OCORRENCIA,IDOCORRENCIA), --idocorrencia
  COALESCE(IDMOTIVOINAD,0),
  VLRATRASO,
  PARCELAATRASO,
  LEFT(IDGRAVACAO,100),
  /*DESCOCORRENCIA*/NULL,
  0/*COALESCE(PARCELAATRASO,1) */
FROM                                                    
   SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE AS A                                                    
  --WHERE                                                                                           
   --NOT EXISTS (SELECT B.IDCALL FROM SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC B WHERE B.IDCALL = A.IDCALL) -- OS168731   
     
   SET @QTD_REGISTROS = @@ROWCOUNT     
  
   UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
     
   IF @QTD_REGISTROS > 0  
   BEGIN  
  INSERT TBL_LOG_CRMDAC(CARTEIRA,DESCRICAO)VALUES('COMERCIAL_NEW','INSERT TABELA CONTROLE')                                                    
  SET @ID_LOG = SCOPE_IDENTITY()  
  
  INSERT INTO SRC.DeepCenter.TBL_CONTROLE_DEEPCENTER_CRMDAC(IDCALL, ID_ACIONA, IDCALL_SINERGYTECH)                                      
  SELECT IDCALL, ID_ACIONA, IDCALL_SINERGYTECH FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE AS A    
  
  SET @QTD_REGISTROS = @@ROWCOUNT     
  
  UPDATE TBL_LOG_CRMDAC SET QTD_REGISTROS = @QTD_REGISTROS, DATA_FIN = GETDATE() WHERE ID = @ID_LOG                                                    
   END                                                                                                 
                                                                                                      
 /******************************************************DROP TABLE SELEÇÕES***********************************************************/                                        
 --IF OBJECT_ID ('SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                   
 --BEGIN         
 -- DROP TABLE SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_TESTE                                   
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_1_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_1_TESTE                                                    
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE') IS NOT NULL                                
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_TESTE                                                    
 --END                        
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_TESTE                                                    
 --END                                                    
                                    
 --IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE') IS NOT NULL                                       
 --BEGIN                                
 -- DROP TABLE SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_TESTE                                                    
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_TESTE                                                    
 --END                                                   
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_TESTE                                                    
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 --BEGIN                             
 -- DROP TABLE SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_TESTE                                                    
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_TESTE                                                    
 --END                                              
                                                
 --IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE') IS NOT NULL                                               
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_TESTE                                                    
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE') IS NOT NULL                            
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_TESTE                                                    
 --END                                                    
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_TESTE                                                    
 --END                        
                                  
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE_AUX_TESTE                                                    
 --END                                   
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE') IS NOT NULL                                                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_TESTE                                                    
 --END                                                   
                                                    
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE') IS NOT NULL                                      
 --BEGIN                                      
 -- DROP TABLE SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_TESTE                                                    
 --END                                                    
                                  
 --IF OBJECT_ID ('SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE') IS NOT NULL                    
 --BEGIN                                                    
 -- DROP TABLE SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_TESTE                                                    
 --END                                     
                                                    
 EXEC stpGravaLogDeepCenter @ID_LOG_GERAL                                                    
                                   
END TRY                                                    
BEGIN CATCH                                                    
 EXEC STP_LOG_ERRO 'ExecucaoDeepCenterBradescoComercialCrmDac_new'                                                    
END CATCH
GO