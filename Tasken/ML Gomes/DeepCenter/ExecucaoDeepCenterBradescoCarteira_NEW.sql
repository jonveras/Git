USE [SRC]
GO

/****** Object:  StoredProcedure [dbo].[ExecucaoDeepCenterBradescoCarteira_NEW]    Script Date: 07/05/2025 13:45:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ExecucaoDeepCenterBradescoCarteira_NEW] (
 @DATA DATE = NULL, @reprocessar bit = 0,@LimpaTabela bit = 0                              
)                                
AS                                
                                
/* *********************************************************************************************** *                                
 * NOME DO OBJETO : ExecucaoRedeBrasilBradescoCarteira              *                                
 * CRIAÇÃO: 12/09/2019                      *                                
 * PROFISSIONAL: LUCAS LIMA                     *                                
 * PROJETO: DEEPCENTER                      *                                 
 * *********************************************************************************************** */                                
                                
BEGIN TRY  

 /******************* OS 171689 *******************/ 
 
	IF CONVERT(DATE, GETDATE()) = '20250501'
	BEGIN
		RETURN;
	END
                                
 /******************* TABELA FINAL DEEPCENTER *******************/                                  
 IF OBJECT_ID('SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CARTEIRA_FINAL') IS NULL                                
 BEGIN                                
  CREATE TABLE SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CARTEIRA_FINAL(                              
   IDUNICO INT IDENTITY(1,1) PRIMARY KEY,                              
   IDCUSTOMER   VARCHAR(500)                                
     ,DATA     DATETIME                                
     ,CPF     VARCHAR(500)                                
     ,CNPJ     VARCHAR(500)                                
     ,CONTRATO    VARCHAR(500)                                
     ,SEGMENTOCANAL   INT                                
     ,IDPERFIL    INT                                
     ,PORTIFOLIO   INT                                
     ,PRODUTOPORTFOLIO   INT                                
     ,CARTEIRA    VARCHAR(500)                                
     ,CARTEIRAMIGRADA  INT                                
     ,GRUPOPRODUTO   VARCHAR(500)                                
     ,PRODUTO    VARCHAR(500)                                
     ,SUBPRODUTO   VARCHAR(500)                                
     ,ATRASO    INT                                
     ,RATING    VARCHAR(500)                                
     ,SCORE     VARCHAR(500)                                
     ,SEGURO    INT                                
     ,TIPOCHEQUE   INT                                
     ,TIPOMANUTENCAOOPER INT                                
     ,IDREMESSA    INT                                
     ,STATUSCHEQUE   INT                                
     ,DATAADESAO   DATE                                
     ,MAILING    INT                                
     ,UF     VARCHAR(500)                                
     ,CIDADE    VARCHAR(500)                                
     ,LOJA     INT                                
     ,LOJISTA    VARCHAR(500)                                
     ,DIRETORIAREG       VARCHAR(500)                                
     ,GERENCIAREG   VARCHAR(500)                                
     ,DATASAFRA    DATE                                
     ,DATASAIDA          DATE                                
     ,STATUSACORDO       VARCHAR(500)                                
     ,VLRPRINC    FLOAT                                
     ,VLRCORRIGIDO   FLOAT                                
     ,PLANO     INT                                
     ,PARCELAATRASO   INT                                
     ,DATAATRASO   DATE                                
     ,CARGODEVEDOR   VARCHAR(500)                                
     ,DATADENASCIMENTO   DATE                                
     ,ESTADOCIVIL   INT  
     ,SEXO     INT                                
     ,COLCHAO INT                              
     ,AGENCIA INT                              
     ,CONTA INT                              
     ,FILA VARCHAR(100)                            
  )                                
 END                                
                                
 /******************* DROPANDO TABELAS SELEÇÃO *******************/                                
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA                                
 END                                
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA                                
 END                                
                        
  IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA                  
 END                          
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA                                
 END                                
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA') IS NOT NULL                         
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA                                
 END                                 
                                 
 IF OBJECT_ID ('SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA') IS NOT NULL                        
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA                                
 END                                
                                
 /******************* ID REMESSA *******************/                                
 DECLARE @ID_REMESSA INT = NULL                                
 EXEC stpGeraIdRemessaDeepCenterNew 'CARTEIRA', '[DBO]', @ID_REMESSA OUTPUT                                
                                 
 /******************* DATA *******************/                                  
 IF @REPROCESSAR = 1 AND @DATA IS NULL                           
 BEGIN                              
  RETURN;                              
 END;                              
                              
 IF @DATA IS NULL                              
 BEGIN                              
  SET @DATA = CAST(GETDATE() AS DATE)                              
 END;                              
                              
 /******************* TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA *******************/                                
                               
 IF @REPROCESSAR = 1                              
 BEGIN                              
  SELECT                                 
   A.CPF_DEV, A.COD_TIPESS, A.COD_ESTCIV, A.COD_SEXO, A.PROFISSAO_DEV, A.DTNASC_DEV, A.ID_DEV,                                
   B.CONTRATO_FIN, B.ATRASO_FIN, B.DTENTRADA_FIN, B.DTDEVOLFICHA_FIN, B.VALOR_FIN, B.COD_CLI, B.VENC_FIN, B.MAXNACORDO_FIN, B.COD_STCB,                               
   C.PERM_CAR, D.CONTRATO_ORIGINAL, E.PORTFOLIODEEPCENTER_CLI, F.PRODPORTFOLIODEEPCENTER_CAR                              
   INTO SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA                                
  FROM                                
   [SRC].dbo.CAD_DEV AS A (NOLOCK)                                
   JOIN [SRC].dbo.CAD_DEVF AS B (NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                
   JOIN [SRC].dbo.CAD_CAR AS C (NOLOCK) ON B.COD_CLI = C.COD_CLI AND B.COD_CAR = C.COD_CAR                                
   JOIN [SRC].dbo.AUX_DEVF AS D (NOLOCK) ON B.CONTRATO_FIN = D.CONTRATO_FIN                                
   JOIN [SRC].dbo.CAD_CLI AS E (NOLOCK) ON B.COD_CLI = E.COD_CLI                   
   JOIN [SRC].dbo.CAD_CAR_AUX_AUX AS F (NOLOCK) ON B.COD_CLI = F.COD_CLI AND B.COD_CAR = F.COD_CAR                                
  WHERE                                
   ((B.COD_CLI IN (3,11,17)) OR (B.COD_CLI = 16 AND A.COD_TIPESS = 1))              
   AND (                              
   (B.STATCONT_FIN = 0)                              
   OR                               
   (B.STATCONT_FIN = 1 AND CONVERT(DATE,B.DTDEVOL_FIN) = @DATA))                              
   AND B.COD_STCB NOT IN (16,126)                              
              
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA(CONTRATO_FIN)                                 
  INCLUDE(CPF_DEV, COD_TIPESS, COD_ESTCIV, COD_SEXO, PROFISSAO_DEV, DTNASC_DEV, ATRASO_FIN, DTENTRADA_FIN, DTDEVOLFICHA_FIN, VALOR_FIN, COD_CLI)                             
                              
 END ELSE                              
 BEGIN                               
  SELECT                                 
   A.CPF_DEV, A.COD_TIPESS, A.COD_ESTCIV, A.COD_SEXO, A.PROFISSAO_DEV, A.DTNASC_DEV, A.ID_DEV,                                
   B.CONTRATO_FIN, B.ATRASO_FIN, B.DTENTRADA_FIN, B.DTDEVOLFICHA_FIN, B.VALOR_FIN, B.COD_CLI, B.VENC_FIN, B.MAXNACORDO_FIN, B.COD_STCB,                               
   C.PERM_CAR, D.CONTRATO_ORIGINAL, E.PORTFOLIODEEPCENTER_CLI, F.PRODPORTFOLIODEEPCENTER_CAR                              
   INTO SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA                               
  FROM                                
   [SRC].dbo.CAD_DEV AS A (NOLOCK)                                
   JOIN [SRC].dbo.CAD_DEVF AS B (NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                
   JOIN [SRC].dbo.CAD_CAR AS C (NOLOCK) ON B.COD_CLI = C.COD_CLI AND B.COD_CAR = C.COD_CAR                                
   JOIN [SRC].dbo.AUX_DEVF AS D (NOLOCK) ON B.CONTRATO_FIN = D.CONTRATO_FIN                                
   JOIN [SRC].dbo.CAD_CLI AS E (NOLOCK) ON B.COD_CLI = E.COD_CLI                              
   JOIN [SRC].dbo.CAD_CAR_AUX_AUX AS F (NOLOCK) ON B.COD_CLI = F.COD_CLI AND B.COD_CAR = F.COD_CAR                                
  WHERE                                
   ((B.COD_CLI IN (3,11,17)) OR (B.COD_CLI = 16 AND A.COD_TIPESS = 1))                      
   AND (B.STATCONT_FIN = 0         
   OR                               
   (B.STATCONT_FIN = 1 AND CONVERT(DATE,B.DTDEVOL_FIN) = @DATA)) --OS 171122    
 AND B.COD_STCB NOT IN (16,126)                              
                                
  CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA(CONTRATO_FIN)                                 
  INCLUDE(CPF_DEV, COD_TIPESS, COD_ESTCIV, COD_SEXO, PROFISSAO_DEV, DTNASC_DEV, ATRASO_FIN, DTENTRADA_FIN, DTDEVOLFICHA_FIN, VALOR_FIN, COD_CLI)                               
 END;                              
                                
 /******************* TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA *******************/                              
 SELECT                               
  CONTRATO_FIN, CARTEIRA, CASE WHEN NOMEPRODUTO = '' THEN NULL ELSE NOMEPRODUTO END AS SUBPRODUTO,                          
  A.COD_EMPRESA, A.AGENCIA, A.CONTACORRENTE, A.FILLER, A.FILA_COBRANCA
  INTO SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA                                
 FROM                               
  [SRC].dbo.AUX_BRADESCOBANCO AS A  (NOLOCK)                               
  LEFT JOIN [SRC].dbo.BRADESCOPRODUTOS AS B ON (B.CODPRODUTO = A.CARTEIRA)                                   
 WHERE                                
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                              
                        
 /******************* TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA *******************/                        
 SELECT                        
  CONTRATO_FIN, CARTEIRA, COD_NATUREZA AS PRODUTO, DESC_NATUREZA AS SUBPRODUTO, TITULO, AGENCIA, CONTA,                        
  AGENCIA_CLIENTE, CONTA_CLIENTE, NUMERO_CARTEIRA, A.FILA_COBRANCA
  INTO SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA                        
 FROM                        
  [SRC].dbo.AUX_BRADESCOLPTITULO AS A WITH(NOLOCK)                        
 WHERE                        
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                              
                                
                                
 /******************* TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA *******************/                                
 SELECT                                
  A.CONTRATO_FIN, A.PARCELA_PARC, A.VENC_PARC, A.VALOR_PARC, A.COD_STPA                       
  INTO SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA                                
 FROM                                
  [SRC].dbo.CAD_DEVP AS A (NOLOCK)                                
 WHERE                                
  COD_STPA = 0 AND VENC_PARC < GETDATE() AND                                
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                
              
 /******************* TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA *******************/                                
 SELECT                                
  A.CONTRATO_FIN, A.PLANO_ACO, A.COD_STAC, B.DESC_STAC, C.PARCELA_ACOP, C.VALOR_ACOP, C.VENC_ACOP, C.COD_STPA                                
  INTO SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA                                  
 FROM                                
  [SRC].dbo.CAD_ACO AS A (NOLOCK)                                
  JOIN [SRC].dbo.CAD_STAC AS B (NOLOCK) ON A.COD_STAC = B.COD_STAC                                
  JOIN [SRC].dbo.CAD_ACOP AS C (NOLOCK) ON A.CONTRATO_FIN = C.CONTRATO_FIN AND A.NACORDO_ACO = C.NACORDO_ACO                                
 WHERE                                
  B.COD_STAC IN (1,7) AND C.COD_STPA = 0 AND C.VENC_ACOP < GETDATE() AND                                
  EXISTS (SELECT * FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA AS D                                 
    WHERE A.CONTRATO_FIN = D.CONTRATO_FIN AND A.NACORDO_ACO = D.MAXNACORDO_FIN)                                
                                
 /******************* TBL_BRADESCO_DIGITAL_FINAL_CARTEIRA *******************/                                
 SELECT                                  
  CASE                                 
   WHEN COALESCE(A.COD_TIPESS,0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(A.CPF_DEV)), 14)                                 
   ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(A.CPF_DEV)), 11)                                 
  END AS IDCUSTOMER,                                
                        
  @DATA AS [DATA],                                 
                                    
  CASE                                 
   WHEN COALESCE(A.COD_TIPESS,0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(A.CPF_DEV)), 14)                                 
   ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(A.CPF_DEV)), 11)                                 
  END AS CPF,                                
                                  
  NULL AS CNPJ,                                     
                                
  --COALESCE(A.CONTRATO_ORIGINAL, LEFT(A.CONTRATO_FIN, CHARINDEX('-', A.CONTRATO_FIN)-1)) AS CONTRATO,                                
  CASE                                 
   WHEN A.COD_CLI IN (16,17) THEN COALESCE(C.TITULO, A.CONTRATO_ORIGINAL)                         
   WHEN CHARINDEX('-', A.CONTRATO_FIN)> 0 THEN COALESCE(A.CONTRATO_ORIGINAL, LEFT(A.CONTRATO_FIN, CHARINDEX('-', A.CONTRATO_FIN)-1))                                 
   ELSE COALESCE(A.CONTRATO_ORIGINAL, A.CONTRATO_FIN)                                
  END AS CONTRATO,                                  
                                
  CASE                     
   WHEN COALESCE(A.COD_TIPESS,0) >= 2 THEN 0            
   ELSE COALESCE(A.COD_TIPESS,0)                                 
  END AS IDPERFIL,                                
                                
  3 AS SEGMENTOCANAL,                                
                                
  --IIF(B.COD_EMPRESA = 'ABLG0000', 6, IIF(R.CPF_DEV IS NOT NULL, 21,                              
  --IIF(A.COD_CLI = 11,                              
  -- CASE                              
  --  WHEN SUBSTRING(J.FILLER, 3, 5) = '3A52' THEN 22                              
  --  WHEN SUBSTRING(J.FILLER, 3, 5) = '2A52' THEN 23                              
  --  WHEN SUBSTRING(J.FILLER, 3, 5) = '4A53' THEN 24                              
  --  WHEN SUBSTRING(J.FILLER, 3, 5) = '7A51' THEN 25                              
  --  WHEN SUBSTRING(J.FILLER, 3, 5) = '8A51' THEN 26                              
  --  WHEN SUBSTRING(J.FILLER, 3, 5) NOT IN ('3A52','2A52','4A53','7A51','8A51') THEN 27                              
  --  ELSE 27                              
  -- END,            
  -- IIF(R.CPF_DEV IS NULL, A.PORTFOLIODEEPCENTER_CLI, 21)                              
  --))) AS PORTIFOLIO,                              
                              
  CASE                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '3A52' THEN 6 -- OS168675                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '2A52' THEN 23                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '4A53' THEN 24                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '7A51' THEN 25           
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '8A51' THEN 26                            
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '6A51' THEN 40 -- OS167390                            
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '1A52' THEN 41 -- OS167390                            
   WHEN A.COD_CLI = 11             THEN 27                              
   WHEN B.COD_EMPRESA = 'ABLG0000'          THEN 6                              
   WHEN R.CPF_DEV IS NOT NULL           THEN 6                              
   ELSE A.PORTFOLIODEEPCENTER_CLI                              
  END AS PORTIFOLIO,                              
                              
  /*IIF(A.COD_CLI = 11,                               
  CASE                              
  WHEN SUBSTRING(J.FILLER, 3, 5) = '3A52' THEN 39                              
  WHEN SUBSTRING(J.FILLER, 3, 5) = '2A52' THEN 40                              
  WHEN SUBSTRING(J.FILLER, 3, 5) = '4A53' THEN 41                              
  WHEN SUBSTRING(J.FILLER, 3, 5) = '7A51' THEN 42                              
  WHEN SUBSTRING(J.FILLER, 3, 5) = '8A51' THEN 43                              
  ELSE 44                              
  END,                    IIF(B.COD_EMPRESA = 'ABLG0000', 32, IIF(R.CPF_DEV IS NULL, A.PRODPORTFOLIODEEPCENTER_CAR, 35))) AS PRODUTOPORTFOLIO,*/                              
  /*CASE                
   WHEN A.PRODPORTFOLIODEEPCENTER_CAR <> -1 THEN A.PRODPORTFOLIODEEPCENTER_CAR                
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '3A52' THEN 39                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '2A52' THEN 40                              
   WHEN A.COD_CLI = 11 AND COALESCE(A.COD_TIPESS,0) = 0 AND SUBSTRING(LTRIM(J.FILLER),3,3) = 'A53'  THEN 1019 -- OS170702          
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '7A51' THEN 42                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '8A51' THEN 43                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '6A51' THEN 52 -- OS167390                              
   WHEN A.COD_CLI = 11 AND SUBSTRING(J.FILLER, 3, 5) = '1A52' THEN 53 -- OS167390                              
   WHEN A.COD_CLI = 11             THEN 44                              
   WHEN B.COD_EMPRESA = 'ABLG0000' THEN 1                              
   WHEN R.CPF_DEV IS NOT NULL           THEN 1 -- OS168675                              
   ELSE A.PRODPORTFOLIODEEPCENTER_CAR                              
  END AS PRODUTOPORTFOLIO,                    */

  -- OS 171731
  CASE                               
   WHEN A.COD_CLI = 11		 THEN (SELECT top 1 PTF.COD_PORTFOLIO FROM DEEPCENTER.CAD_PORTFOLIO AS PTF WHERE PTF.FILA_COBRANCA = J.FILA_COBRANCA)
   WHEN A.COD_CLI IN (16,17) THEN (SELECT top 1 PTF.COD_PORTFOLIO FROM DEEPCENTER.CAD_PORTFOLIO AS PTF WHERE PTF.FILA_COBRANCA = C.FILA_COBRANCA)
   ELSE							  (SELECT top 1 PTF.COD_PORTFOLIO FROM DEEPCENTER.CAD_PORTFOLIO AS PTF WHERE PTF.FILA_COBRANCA = B.FILA_COBRANCA)
  END AS PRODUTOPORTFOLIO,                    

  --A.PRODPORTFOLIODEEPCENTER_CAR AS PRODUTOPORTFOLIO,                                               
  --IIF(A.PORTFOLIODEEPCENTER_CLI = 7, 'EAVM', SUBSTRING(B.CARTEIRA,PATINDEX('%[a-z,1-9]%',B.CARTEIRA),LEN(B.CARTEIRA ))) AS CARTEIRA,                                
  case                        
 WHEN A.COD_CLI IN (16,17) THEN SUBSTRING(C.CARTEIRA,PATINDEX('%[a-z,1-9]%',C.CARTEIRA),LEN(C.CARTEIRA ))                        
 when A.PORTFOLIODEEPCENTER_CLI = 7 then 'EAVM'                        
 else SUBSTRING(B.CARTEIRA,PATINDEX('%[a-z,1-9]%',B.CARTEIRA),LEN(B.CARTEIRA ))                        
  end as CARTEIRA,                        
                          
  IIF(A.COD_CLI IN (3,16,17) ,NULL, 0) AS CARTEIRAMIGRADA,                                
                              
  NULL AS GRUPOPRODUTO,                                 
                          
  --IIF(A.PORTFOLIODEEPCENTER_CLI = 7, J.DESCRIAO, B.SUBPRODUTO) AS PRODUTO,                         
  case                        
 WHEN A.COD_CLI IN (16,17) THEN C.SUBPRODUTO                        
 when A.PORTFOLIODEEPCENTER_CLI = 7 then J.DESCRIAO               
 else  B.SUBPRODUTO                        
  end AS PRODUTO,                         
                               
  IIF(A.PORTFOLIODEEPCENTER_CLI = 7, J.DESCRIAO, NULL) AS SUBPRODUTO,                                
                                
  A.ATRASO_FIN AS ATRASO,                               
                                  
  CASE                                 
   WHEN A.ATRASO_FIN BETWEEN 60 AND 90  THEN 'FASE 1'                                
   WHEN A.ATRASO_FIN BETWEEN 91 AND 120 THEN 'FASE 2'                                
   WHEN A.ATRASO_FIN BETWEEN 121 AND 150 THEN 'FASE 3'                                
   WHEN A.ATRASO_FIN BETWEEN 151 AND 180 THEN 'FASE 4'                                
   WHEN A.ATRASO_FIN BETWEEN 181 AND 360 THEN 'FASE 5'                                
   WHEN A.ATRASO_FIN BETWEEN 361 AND 720 THEN 'FASE 6'                                
   WHEN A.ATRASO_FIN BETWEEN 721 AND 1080 THEN 'FASE 7'                                
   WHEN A.ATRASO_FIN BETWEEN 1081 AND 1440 THEN 'FASE 8'                                
   WHEN A.ATRASO_FIN BETWEEN 1441 AND 1800 THEN 'FASE 9'                                
   WHEN A.ATRASO_FIN BETWEEN 1801 AND 2160 THEN 'FASE 10'                                
   WHEN A.ATRASO_FIN BETWEEN 2160 AND 2520 THEN 'FASE 11'                                
   WHEN A.ATRASO_FIN BETWEEN 2521 AND 2880 THEN 'FASE 12'                                
   WHEN A.ATRASO_FIN BETWEEN 2881 AND 3240 THEN 'FASE 13'                       
   WHEN A.ATRASO_FIN BETWEEN 3241 AND 3600 THEN 'FASE 14'                                
   WHEN A.ATRASO_FIN > 3600    THEN 'FASE 15'                                
  END AS RATING,                                  
                               
  NULL AS SCORE,                                
  NULL AS SEGURO,                                
  NULL AS TIPOCHEQUE,                                
  NULL AS TIPOMANUTENCAOOPER,                                
  @ID_REMESSA AS IDREMESSA,                                
  --1 AS IDREMESSA,                                
  NULL AS STATUSCHEQUE,                                  
  CAST(NULL AS DATE) AS DATAADESAO,        
  NULL AS MAILING,                                
  CASE F.DESC_UF WHEN '--' THEN NULL ELSE F.DESC_UF END AS UF,                                 
  F.CIDADE_END AS CIDADE,                                
  NULL AS LOJA,                                
  NULL AS LOJISTA,                                
  NULL AS DIRETORIAREG,                                
  NULL AS GERENCIAREG,                                
  CAST(A.DTENTRADA_FIN AS DATE) AS DATASAFRA,                                
  --CAST(DATEADD(DAY,COALESCE(A.PERM_CAR,0), A.DTENTRADA_FIN) AS DATE) AS DATASAIDA,                                
  '' AS DATASAIDA,                              
  COALESCE(H.DESC_STAC, 'EM ABERTO') AS STATUSACORDO,                                
  A.VALOR_FIN AS VLRPRINC,                                
                                
  CASE WHEN COALESCE(H.COD_STAC, 0) IN (1,7) THEN E.VLRCORRIGIDO ELSE D.VLRCORRIGIDO END AS VLRCORRIGIDO,                                 
  CASE WHEN COALESCE(H.COD_STAC, 0) IN (1,7) THEN H.PLANO ELSE D.PLANO END AS PLANO,                                  
  CASE WHEN COALESCE(H.COD_STAC, 0) IN (1,7) THEN E.PARCELAATRASO ELSE D.PARCELAATRASO END AS PARCELAATRASO,                                
  CASE WHEN COALESCE(H.COD_STAC, 0) IN (1,7) THEN E.DATAATRASO ELSE D.DATAATRASO END AS DATAATRASO,                         
  --A.VENC_FIN AS DATAATRASO,                                
                              
CASE WHEN                               
   RTRIM(LTRIM(SUBSTRING(A.PROFISSAO_DEV,PATINDEX('%[a-z]%',A.PROFISSAO_DEV), LEN(A.PROFISSAO_DEV)))) = '' THEN NULL                                 
   ELSE SUBSTRING(A.PROFISSAO_DEV,PATINDEX('%[a-z]%',A.PROFISSAO_DEV), LEN(A.PROFISSAO_DEV))                               
  END AS CARGODEVEDOR,                      
                                
  CASE WHEN A.DTNASC_DEV BETWEEN DATEADD(YEAR, - 100, GETDATE()) AND GETDATE() THEN A.DTNASC_DEV ELSE NULL END AS DATADENASCIMENTO,                                
                                
  CASE COALESCE(A.COD_ESTCIV,0)                                
   WHEN 0 THEN 4                                
   WHEN 1 THEN 0                
   WHEN 2 THEN 1                                
   WHEN 3 THEN 3                                
   WHEN 4 THEN 2                                
  END AS ESTADOCIVIL,                                
                                
  CASE COALESCE(A.COD_SEXO,0)                                
   WHEN 0 THEN 2                                
   WHEN 1 THEN 0                                
   WHEN 2 THEN 1                                
  END AS SEXO ,                              
                                
  CASE                              
   WHEN A.COD_STCB = 127 THEN 0                              
   WHEN A.COD_STCB IN (11,13,125) THEN 1                              
   --WHEN A.COD_STCB IN (16,126) THEN 9999                              
   ELSE 0                              
  END AS COLCHAO,                              
                              
                                
  CASE                               
   WHEN A.COD_CLI = 11 THEN SUBSTRING(J.AGENCIA,PATINDEX('%[1-9]%',J.AGENCIA),10)                              
   WHEN A.COD_CLI IN (16,17) THEN COALESCE(C.AGENCIA_CLIENTE, C.AGENCIA)                       
   ELSE SUBSTRING(B.AGENCIA,PATINDEX('%[1-9]%',B.AGENCIA),10)                              
  END AS AGENCIA,                              
                              
  CASE                               
   WHEN A.COD_CLI = 11 THEN SUBSTRING(J.CONTA,PATINDEX('%[1-9]%',J.CONTA),10)                              
   WHEN A.COD_CLI IN (16,17) THEN COALESCE(C.CONTA_CLIENTE, C.CONTA)                        
   ELSE SUBSTRING(B.CONTACORRENTE,PATINDEX('%[1-9]%',B.CONTACORRENTE),10)                              
  END AS CONTA,                              
                              
  CASE                               
  WHEN A.COD_CLI = 11 AND J.FILLER IS NULL   THEN 'A51'              
   WHEN A.COD_CLI = 11 AND RTRIM(LTRIM(J.FILLER)) = '' THEN 'A51'                              
   WHEN A.COD_CLI = 11            THEN SUBSTRING(ltrim(J.FILLER), 3, 5)                              
                              
   WHEN A.COD_CLI = 3 AND B.FILLER IS NULL    THEN 'A08'                              
   WHEN A.COD_CLI = 3 AND RTRIM(LTRIM(B.FILLER)) = ''  THEN 'A08'                              
   WHEN A.COD_CLI = 3            THEN SUBSTRING(ltrim(B.FILLER), 3, 5)                              
   WHEN A.COD_CLI IN (16,17) THEN COALESCE(C.NUMERO_CARTEIRA, C.CARTEIRA)                        
  END AS FILA                              
                              
  INTO SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA                              
 FROM       
  SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA AS A                                
                                
  OUTER APPLY (SELECT TOP 1 * FROM SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN) AS B                                
  OUTER APPLY (SELECT TOP 1 * FROM SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA AS C WHERE A.CONTRATO_FIN = C.CONTRATO_FIN) AS C                                
                                  
  OUTER APPLY ( SELECT                                 
        SUM(D.VALOR_PARC) AS VLRCORRIGIDO,                                
        MIN(D.PARCELA_PARC) AS PARCELAATRASO,                                
        MIN(D.VENC_PARC) AS DATAATRASO,                                
        COUNT(PARCELA_PARC) AS PLANO                                
       FROM SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA AS D                                
       WHERE A.CONTRATO_FIN = D.CONTRATO_FIN                                
  ) AS D                                
                                
  OUTER APPLY ( SELECT                                 
      SUM(E.VALOR_ACOP) AS VLRCORRIGIDO,                                
      MIN(E.PARCELA_ACOP) AS PARCELAATRASO,                                
      MIN(E.VENC_ACOP) AS DATAATRASO                                
   FROM SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA AS E                                
   WHERE A.CONTRATO_FIN = E.CONTRATO_FIN                                   
  ) AS E                                
                                
  OUTER APPLY(SELECT TOP 1 G.DESC_UF, F.CIDADE_END FROM [SRC].dbo.CAD_DEVE AS F                                
   JOIN [SRC].dbo.CAD_UF AS G ON G.COD_UF = F.COD_UF                                
     WHERE F.CPF_DEV = A.CPF_DEV                             
  ORDER BY F.PERC_END DESC                               
  ) AS F                                
                                
  OUTER APPLY ( SELECT TOP 1 H.COD_STAC, H.DESC_STAC, COUNT(*) AS PLANO                                
      FROM SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA AS H                                
      WHERE A.CONTRATO_FIN = H.CONTRATO_FIN                                
      GROUP BY H.COD_STAC, H.DESC_STAC                                   
  ) AS H                                
                              
  OUTER APPLY (SELECT TOP 1 DESCRIAO, FILLER, AGENCIA, CONTA, FILA_COBRANCA
      FROM AUX_CARTOESBRADESCO (NOLOCK) AS J WHERE J.CONTRATO_FIN = A.CONTRATO_FIN) AS J                              
                              
  LEFT JOIN TBL_BRADESCO_PORTOLIO_35 AS R WITH (NOLOCK) ON R.CPF_DEV = A.CPF_DEV                            
                    
  -- OS 169641 - WHERE F.DESC_UF NOT IN ('RS') -- OS167522 - Retirar RS                            
                                
 /******************* TABELA INTERNA DE CONTROLE *******************/                                
 IF @LIMPATABELA = 1                                
 BEGIN                                
  TRUNCATE TABLE SRC.DeepCenter.TBL_DEEPCENTER_BRADESCO_CARTEIRA_FINAL                  
 END;                                
                  
 -- OS 171731
 --UPDATE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA SET PRODUTOPORTFOLIO = 1006 WHERE PRODUTOPORTFOLIO = 43;                  
 --UPDATE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA SET PRODUTOPORTFOLIO = 1007 WHERE PRODUTOPORTFOLIO = 1;                  
 --UPDATE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA SET PRODUTOPORTFOLIO = 1023 WHERE PRODUTOPORTFOLIO = 2;                  
 --UPDATE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA SET PRODUTOPORTFOLIO = 1025 WHERE PRODUTOPORTFOLIO = 42;                  
 --UPDATE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA SET PRODUTOPORTFOLIO = 1032 WHERE PRODUTOPORTFOLIO = 52;                  
 --UPDATE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA SET PRODUTOPORTFOLIO = 1036 WHERE PRODUTOPORTFOLIO = 44;                  
                                                            
  DELETE A                                
  OUTPUT                                                   
   'MLGomes',GETDATE(),DELETED.DATA,DELETED.CONTRATO,DELETED.IDCUSTOMER,DELETED.CPF,COALESCE(DELETED.PARCELAATRASO,1),                    
   DELETED.PLANO,DELETED.SEGMENTOCANAL,COALESCE(DELETED.FILA,''),COALESCE(DELETED.PRODUTOPORTFOLIO,0),0,DELETED.VLRCORRIGIDO,DELETED.VLRPRINC,COALESCE(DELETED.ATRASO,0),                     
   COALESCE(DELETED.UF,'SP'),COALESCE(DELETED.CIDADE,'SÃO PAULO'),1,NULL,DELETED.COLCHAO,DELETED.DATADENASCIMENTO,DELETED.SCORE,DELETED.DATASAFRA,NULL                                          
                      
  INTO [DeepCenter].[FINAL_CARTEIRA] (
  DSNOMEASSESSORIA,DTDATAINSERCAO,DTDATAREFERENCIA,NUMCONTRACT,NUMCUSTOMER,NUMCLIENTE,NUMPARCELA,                    
  NUMTOTALPARCELAS,NUMSEGMENTO,DSSTATE,NUMPORTFOLIO,NUMRISCO,VLRVALOREMABERTO,VLRVALORDIVIDA,NUMATRASO,                    
  DSUF,DSCIDADE,NUMSTATUSCOBRANCA,DSSUSPENSAO,NUMCOLCHAO,DTNASCIMENTO,NUMSCORE,DTSAFRA,NUMRESTRICAO                    
  )                              
  FROM                                
   SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA AS A                                                  
                                
 /******************* DROPANDO TABELAS SELEÇÃO *******************/                                
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVF_BRADESCO_CARTEIRA                                
 END                                
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUXBRADESCOBANCO_DADOSAUX_BRADESCO_CARTEIRA                                
 END                                
                        
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_VW_AUX_BRADESCOLPCONTRATO_BRADESCO_CARTEIRA                                
 END                          
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_DEVP_BRADESCO_CARTEIRA                                
 END                                
                                
 IF OBJECT_ID ('SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_SELECAO_CAD_ACO_BRADESCO_CARTEIRA                                
 END                                
                                 
 IF OBJECT_ID ('SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA') IS NOT NULL                                
 BEGIN                                
  DROP TABLE SRC.DeepCenter.TBL_BRADESCO_FINAL_CARTEIRA             
 END                                
                                
END TRY                                
BEGIN CATCH                                
 EXEC STP_LOG_ERRO 'ExecucaoDeepCenterBradescoCarteira'                                
END CATCH 
GO


