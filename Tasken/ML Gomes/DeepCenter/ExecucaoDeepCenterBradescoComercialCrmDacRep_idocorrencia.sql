USE [SRC]
GO

ALTER PROC [dbo].[ExecucaoDeepCenterBradescoComercialCrmDacRep_idocorrencia](
 @DATA DATE = NULL, @QTD INT OUTPUT                                               
)                                                    
AS                                                    
/* *********************************************************************************************** *                                                  
 * NOME DO OBJETO : ExecucaoDeepCenterBradescoComercialCrmDac_rep_idocorrencia					   *                                                  
 * CRIAÇÃO: 08/05/2025														                       *                                                  
 * PROFISSIONAL: Jonathan Veras																	   *                                                  
 * PROJETO: DEEPCENTER																			   *                                                   
 * *********************************************************************************************** */                                                  
BEGIN TRY                                                    
                                                     
/***************************************** DROP TABLE SELEÇÕES *******************************************/        
	IF OBJECT_ID ('SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP                                                    
	END      
 
	IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_1_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_1_REP                                                    
	END                                                    
                               
	IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP                                                    
	END                                                    
                                                  
	IF OBJECT_ID ('SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP                                                    
	END                                                    
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP') IS NOT NULL                           
	BEGIN                                              
	DROP TABLE SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP                                                    
	END                                                   
                             
	IF OBJECT_ID ('SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP                            
	END                                                    
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP                                                    
	END                                                    
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                   
		DROP TABLE SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP                                                    
	END                                                    
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP') IS NOT NULL                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP                                                    
	END                                                    
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_REP') IS NOT NULL                                         
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_REP                           
	END     
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                            
		DROP TABLE SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP                                                    
	END              
                        
	IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP                                             
	END                                            
                                   
	IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP                                                    
	END                                   
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP') IS NOT NULL           
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP                                                    
	END                                                    
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_REP') IS NOT NULL                   
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_REP                                                    
	END                                                    
                                                  
	IF OBJECT_ID ('SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP') IS NOT NULL                                                    
	BEGIN                                                    
		DROP TABLE SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP                                                    
	END
	
    DECLARE @QTD_OLOS INT = 0, @QTD_SINERGY INT = 0                                                 
	/****************************************************** SELEÇÕES ***********************************************************/                                      
 
	--DECLARE @DATA DATE = '20250401' --TESTE
	IF OBJECT_ID ('SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP') IS NULL                                                    
	BEGIN                                    
		WITH CTE AS (           
			SELECT                                                     
				A.ID AS ID_ACIONA, A.CONTRATO_FIN, A.DATA_ACIONA, A.COD_RECUP, A.COD_ACIONAMENTO, A.TEL_TEL, A.DDD_TEL,                                                     
				B.DESC_ACIONAMENTO, B.CODACIONADEEPCENTER_ACIONAMENTO, B.DESCRICAODEEPCENTER_ACIONAMENTO, TIPOCANALDEEPCENT_ACIONAMENTO                          
				,C.ID_ENQUETE, C.ID_RESPOSTA        
				,ROW_NUMBER() OVER (PARTITION BY A.DATA_ACIONA, A.COD_RECUP, A.COD_ACIONAMENTO, A.TEL_TEL, A.DDD_TEL ORDER BY A.ID) AS SEQNUM 
			FROM                                                     
				[SRC].DBO.ACIONA  AS A (NOLOCK)                              
				JOIN [SRC].DBO.CAD_ACIONAMENTO AS B (NOLOCK) ON A.COD_ACIONAMENTO = B.COD_ACIONAMENTO           
				LEFT JOIN TBL_RECUP_RESPOSTAS_ENQUETES AS C ON A.ID = C.ID_ACIONA        
			WHERE                                                     
				CAST(DATA_ACIONA AS DATE) = @DATA
				AND EXISTS ( 
					SELECT 
						* 
					FROM 
						[SRC].DBO.CAD_DEVF AS B (NOLOCK) 
					WHERE 
						A.CONTRATO_FIN = B.CONTRATO_FIN AND B.COD_CLI IN (3,11,16,17)           
						AND B.STATCONT_FIN = 0
				) --OS171361                                                  
				AND TIPOCANALDEEPCENT_ACIONAMENTO <> 10                                   
		)                                    
		SELECT 
			ID_ACIONA, CONTRATO_FIN, DATA_ACIONA, COD_RECUP, COD_ACIONAMENTO, TEL_TEL, DDD_TEL,                                  
			DESC_ACIONAMENTO, CODACIONADEEPCENTER_ACIONAMENTO, DESCRICAODEEPCENTER_ACIONAMENTO, TIPOCANALDEEPCENT_ACIONAMENTO,ID_ENQUETE, ID_RESPOSTA        
		INTO
			SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP                                    
		FROM 
			CTE A                                    
		WHERE 
			SEQNUM = 1
	
		CREATE NONCLUSTERED INDEX CL_IX ON SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP(ID_ACIONA)                                                    
		CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP(CONTRATO_FIN)                              
		CREATE NONCLUSTERED INDEX NON_IX10_teste ON SRC.DeepCenter.[ACIONA_BRADESCO_SELECAO] ([TEL_TEL])                                                     
			INCLUDE ([ID_ACIONA],[CONTRATO_FIN],[DATA_ACIONA],[COD_RECUP],[COD_ACIONAMENTO])                                                    
	END 

 --select * from SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP
                                                                                                      
------------------------------------------------------------------------------------------------------
                                                  
	IF OBJECT_ID ('SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP') IS NULL                                        
	BEGIN                                     
		IF OBJECT_ID ('TEMPDB.dbo.#TEMP_TAB_IDLIGACAODISCADOR_ACIONA') IS NOT NULL                      
		BEGIN                  
			DROP TABLE #TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                                  
		END                                                  
                                                  
		SELECT                                                     
			ID_ACIONA, ID_LIGACAO AS IDCALL, ID_CAMPANHA, CODIGO_CAMPANHA, TIPO_LIGACAO, DISCADOR, CONTRATO_FIN                                                    
		INTO 
			#TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                                  
		FROM                                                     
			[SRC].DBO.TAB_IDLIGACAODISCADOR_ACIONA AS A (NOLOCK)                               
		WHERE                                                     
			EXISTS (
				SELECT 
					* 
				FROM 
					SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP AS B 
				WHERE 
					A.ID_ACIONA = B.ID_ACIONA
			)                                                    
		--SELECT * FROM #TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                           
		SELECT                                           
			* 
		INTO 
			SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP                                                    
		FROM (                                                  
			SELECT 
				*, ROW_NUMBER() OVER(PARTITION BY IDCALL, CONTRATO_FIN ORDER BY IDCALL) AS RW                                                  
			FROM 
				#TEMP_TAB_IDLIGACAODISCADOR_ACIONA                                                  
			) AS X                                               
		WHERE 
			RW = 1
	
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP (ID_ACIONA) INCLUDE (IDCALL)                                                    
		CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP(IDCALL)                                                 
		CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP(IDCALL, DISCADOR)                                                  
	END
	
	--select * from SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP
                                                  
 ------------------------------------------------------------------------------------------------------                     
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP') IS NULL                                                    
	BEGIN                                           
		SELECT      
			IDCALL,DATA,HORAINICIO,HORAFIM,CPF,CONTRATO,PHONENUMBER,TIPODISCAGEM,TIPOATENDIMENTO,TEMPOFALANDO,TEMPOTABULANDO               
			,TEMPOCHAMADA,TEMPOESPERA,DESLIGADOPOR, MAILING, IDGRAVACAO                                         
		INTO 
			SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP                                                    
		FROM                     
			SRC.[DEEPCENTER].DISCAGENS_OLOS AS A (NOLOCK)                                                    
		WHERE                                                    
			EXISTS (
				SELECT 
					* 
				FROM 
					SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP (NOLOCK) AS B 
				WHERE 
					A.IDCALL = B.IDCALL
			)
			AND TIPODISCAGEM != 4 --OS 166643

		SET @QTD_olos = @@ROWCOUNT	
		CREATE NONCLUSTERED INDEX NON_IX  ON SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP (IDCALL)                                                    
	END     
 
 --select * from SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP

 ------------------------------------------------------------------------------------------------------                                     
                                                  
	IF OBJECT_ID ('SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP') IS NULL                                                    
	BEGIN                               
		SELECT                                                   
			CALLRESULTID AS IDCALL_SINERGYTECH, TEMPO_FALADO AS TEMPOFALANDO, TEMPO_DISCAGEM AS TEMPOCHAMADA                                                  
		INTO 
			SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP                                                
		FROM 
			TBL_RESULTADODISCAGEM_SINERGYTECH (NOLOCK) AS A                                                  
		WHERE 
			EXISTS (
				SELECT 
					* 
				FROM 
					SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP (NOLOCK) AS B 
				WHERE 
					A.CALLRESULTID = B.IDCALL AND B.DISCADOR = 'SINERGYTECH'
			)                                                                                                 
		SET @QTD_sinergy = @@ROWCOUNT                                              
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP (IDCALL_SINERGYTECH) INCLUDE(TEMPOFALANDO, TEMPOCHAMADA)                                                  
	END
	
 --select * from SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP

	IF (@QTD_SINERGY = 0 AND @QTD_OLOS = 0)                                                  
	BEGIN                                                  
		RETURN                                                  
	END                                                  
                                                  
 ------------------------------------------------------------------------------------------------------                                            
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP') IS NULL     
	BEGIN                                                    
		SELECT                                                     
			A.CONTRATO_FIN, A.COD_CLI, A.COD_CAR, A.ATRASO_FIN, A.DTENTRADA_FIN, CAST(A.VALOR_FIN AS NUMERIC(15,2)) AS VALOR_FIN, A.COD_STCB,                                                    
			B.CPF_DEV, B.NOME_DEV, B.COD_TIPESS, B.COD_UF,                                         
			C.PORTFOLIODEEPCENTER_CLI, D.PRODPORTFOLIODEEPCENTER_CAR                                
			,B.EMAIL_DEV                                
			,A.PLANO_FIN                                
		INTO 
			SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP                                          
		FROM                                                     
			[SRC].dbo.CAD_DEVF AS A (NOLOCK)                                                    
			JOIN [SRC].dbo.CAD_DEV AS B (NOLOCK) ON A.CPF_DEV = B.CPF_DEV                                                    
			JOIN [SRC].dbo.CAD_CLI AS C (NOLOCK) ON A.COD_CLI = C.COD_CLI                                                  
			JOIN [SRC].dbo.CAD_CAR_AUX_AUX AS D (NOLOCK) ON A.COD_CLI = D.COD_CLI AND A.COD_CAR = D.COD_CAR                                                   
		WHERE                                                     
			EXISTS (SELECT * FROM SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                    
			AND A.COD_CLI IN (3,11,16,17)                                                    
                                                    
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP (CONTRATO_FIN)                                                    
		INCLUDE(CPF_DEV, COD_CLI, COD_CAR, ATRASO_FIN, DTENTRADA_FIN, VALOR_FIN )                                                    
                                          
		CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP (CPF_DEV)                                                    
		INCLUDE(CONTRATO_FIN, COD_CLI, COD_CAR, ATRASO_FIN, DTENTRADA_FIN, VALOR_FIN )                                                    
                                                    
		CREATE NONCLUSTERED INDEX NON_IX2 ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP (CONTRATO_FIN)                                                    
		CREATE NONCLUSTERED INDEX NON_IX3 ON SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP (CPF_DEV)                                                    
	END      
 
 --select * from SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP
                                                    
------------------------------------------------------------------------------------------------------     
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP') IS NULL                                     
	BEGIN                                                    
		SELECT                                                     
			CONTRATO_FIN, CONTRATO_ORIGINAL                                                    
		INTO 
			SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP                                                    
		FROM                                                    
			[SRC].DBO.AUX_DEVF AS A  (NOLOCK)                                                    
		WHERE                                                     
			EXISTS (
				SELECT 
					* 
				FROM 
					SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS B 
				WHERE 
					A.CONTRATO_FIN = B.CONTRATO_FIN
			)                                                  
                                                    
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP (CONTRATO_FIN) INCLUDE (CONTRATO_ORIGINAL)                                                    
	END                                                    
 
 --select * from SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP
                                                
 ------------------------------------------------------------------------------------------------------                                                  
    --DECLARE @DATA DATE = '20250401' PARA TESTE                                             
	IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP') IS NULL                                                    
	BEGIN                                                    
		SELECT                                                     
			CONTRATO_FIN                 
			,CAST(VALOR_ACOP AS NUMERIC(15,2)) AS VALOR_ACOP                                                   
			,PARCELA_ACOP                                
			,TIPO_PARCACO                                                    
		INTO 
			SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP                                                    
		FROM                                                     
			[SRC].DBO.CAD_ACOP AS A (NOLOCK)                                                    
		WHERE                                        
			EXISTS ( SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS B WHERE A.CONTRATO_FIN = B.CONTRATO_FIN)                                                    
			AND COD_STPA = 0 AND CAST(VENC_ACOP AS DATE) < @DATA

		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP (CONTRATO_FIN, PARCELA_ACOP, TIPO_PARCACO)                                                    
		INCLUDE (VALOR_ACOP)                                      
                                       
		CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP (CONTRATO_FIN, VALOR_ACOP)                                         
	END   
 
 --select * from SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP
                                                  
 ------------------------------------------------------------------------------------------------------                                                  
                                               
	IF OBJECT_ID ('SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP') IS NULL                                                    
	BEGIN                                        
		SELECT                                                     
			CONTRATO_FIN                                                    
			,SUM(VALOR_ACOP) AS VLRATRASO                    
			,COUNT(*) AS PARCELAATRASO                                  
		INTO 
			SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP                                                    
		FROM                                                     
			SRC.DeepCenter.CAD_ACOP_BRADESCO_SELECAO_REP AS A (NOLOCK)                                                    
		GROUP BY 
			CONTRATO_FIN
                                                    
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP (CONTRATO_FIN)                                                    
			INCLUDE (VLRATRASO, PARCELAATRASO)                                                   
	END                                                 
 
 --select * from SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP
                                                  
 ------------------------------------------------------------------------------------------------------                                                  
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP') IS NULL                                           
	BEGIN                     
		SELECT 
			CPF_DEV, DDD_TEL, TEL_TEL, PERC_TEL, POSSUIWHATSAPP_TEL, COD_TEL                                                  
		INTO 
			SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP                                          
		FROM                                                     
		[SRC].DBO.CAD_DEVT  AS A  (NOLOCK)                                                    
		WHERE                                                     
		EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS B WHERE A.CPF_DEV = B.CPF_DEV)                                                    
		AND PERC_TEL > 0                                                    
                                
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP (CPF_DEV, DDD_TEL, TEL_TEL)                                                    
		CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP (CPF_DEV) INCLUDE (DDD_TEL, TEL_TEL, PERC_TEL, POSSUIWHATSAPP_TEL, COD_TEL)                                                    
                                                    
	END                                                    
 
 --select * from SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP
                                                  
 ------------------------------------------------------------------------------------------------------                            
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP') IS NULL                                                    
	BEGIN                                                    
		SELECT 
			CPF_DEV, CIDADE_END, COD_UF, PERC_END, DTINCLUSAO_END, COD_END --CASE WHEN COD_TIPO > 2 THEN 9 ELSE COD_TIPO END AS ORDEM                                                
		INTO 
			SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP                                                    
		FROM                                                     
			[SRC].DBO.CAD_DEVE AS A (NOLOCK)                                                    
		WHERE                                        
			EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS B WHERE A.CPF_DEV = B.CPF_DEV)
                                                     
		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP (CPF_DEV) INCLUDE (CIDADE_END, COD_UF, PERC_END, DTINCLUSAO_END/*, ORDEM*/)                                                  
		CREATE NONCLUSTERED INDEX NON_IX1 ON SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP (CPF_DEV, COD_UF) INCLUDE(CIDADE_END, PERC_END, DTINCLUSAO_END/*, ORDEM*/)                                                  
	END
 
 --select * from SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP                                              
                         
 ------------------------------------------------------------------------------------------------------                                                  
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP') IS NULL                                                    
	BEGIN                                        
		SELECT 
			CONTRATO_FIN, CARTEIRA, CASE WHEN NOMEPRODUTO = '' THEN NULL ELSE NOMEPRODUTO END AS NOMEPRODUTO, 2 AS FLAG, A.COD_EMPRESA                                                  
		INTO 
			SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP     
		FROM                              
			[SRC].dbo.AUX_BRADESCOBANCO AS A  (NOLOCK)                         
			LEFT JOIN [SRC].dbo.BRADESCOPRODUTOS AS B ON (B.CODPRODUTO = A.CARTEIRA)                                                       
		WHERE                                   
			EXISTS (SELECT * FROM SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS C WHERE A.CONTRATO_FIN = C.CONTRATO_FIN)

		CREATE NONCLUSTERED INDEX NON_IX ON SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP (CONTRATO_FIN) INCLUDE(CARTEIRA, NOMEPRODUTO, FLAG)                                                    
	END                                       
 
 --select * from SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP
                                          
------------------------------------------------------------------------------------------------------                                                  
                                                    
	IF OBJECT_ID ('SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_REP') IS NULL                            
	BEGIN                                           
	SELECT                                          
		CONTRATO_FIN, CARTEIRA AS CARTEIRA, COD_NATUREZA AS PRODUTO, DESC_NATUREZA AS SUBPRODUTO, TITULO, AGENCIA, CONTA,                                          
		AGENCIA_CLIENTE, CONTA_CLIENTE, TRY_CONVERT(VARCHAR,NUMERO_CARTEIRA) AS NUMERO_CARTEIRA                                        
	INTO 
		SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_REP                                          
	FROM                                          
		[SRC].DBO.AUX_BRADESCOLPTITULO AS A WITH(NOLOCK)                                          
	WHERE                                          
		EXISTS (
			SELECT 
				* 
			FROM 
				SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS B 
			WHERE 
				A.CONTRATO_FIN = B.CONTRATO_FIN
		)
	END                                                    
 
 --select * from SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_REP
                                                    
 /****************************************************** JUNÇÃO ACIONA / DISCADOR ***********************************************************/                                                      
                                                  
	SELECT 
		*                                              
	INTO 
		SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_REP                                                    
	FROM (     
		SELECT                                                   
			A.*, B.IDCALL, B.PHONENUMBER, --IIF(B.TIPODISCAGEM=2,1,B.TIPODISCAGEM) AS TIPODISCAGEM, - -retirado na OS 156136    
			CASE                                                  
				--WHEN C.TIPO_LIGACAO = 2 THEN 4 -- ACRESCENTADO NA OS 156136                                                  
				WHEN C.TIPO_LIGACAO = 2 THEN 5 --ACRESCENTADO NA OS 156650                                                  
				WHEN B.TIPODISCAGEM=2 THEN 1                                                  
				ELSE                                                   
				B.TIPODISCAGEM                                                  
			END AS TIPODISCAGEM,                                                   
			B.TIPOATENDIMENTO,B.TEMPOFALANDO, B.IDGRAVACAO, B.HORAINICIO, B.HORAFIM,                                                  
			B.TEMPOTABULANDO,B.TEMPOCHAMADA,B.TEMPOESPERA, B.DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, C.TIPO_LIGACAO,                         
			LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA /*B.HORA*/, NULL AS IDCALL_SINERGYTECH, B.MAILING         
		FROM 
			SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP AS A (NOLOCK)                                                    
			JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP AS C (NOLOCK) ON C.ID_ACIONA = A.ID_ACIONA                                                    
			JOIN SRC.DeepCenter.TBL_DEEPCENTER_DISCADOR_OLOS_BRADESCO_SELECAO_2_REP AS B (NOLOCK) ON B.IDCALL = C.IDCALL                                                  
		WHERE 
			A.TIPOCANALDEEPCENT_ACIONAMENTO NOT IN (4,10)                                                  
                                                    
		UNION ALL                                                  
                              
		SELECT 
			A.*, A.ID_ACIONA AS IDCALL, COALESCE(A.DDD_TEL,'')+COALESCE(A.TEL_TEL,'') AS PHONENUMBER, 2 AS TIPODISCAGEM, 1 AS TIPOATENDIMENTO, NULL AS TEMPOFALANDO,                                 
			NULL AS IDGRAVACAO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAINICIO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAFIM,                                                   
			NULL AS TEMPOTABULANDO, NULL AS TEMPOCHAMADA, NULL AS TEMPOESPERA, NULL AS DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, C.TIPO_LIGACAO,                                                   
			LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA, NULL AS IDCALL_SINERGYTECH, NULL AS MAILING          
		FROM 
			SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP AS A (NOLOCK)                                                  
			LEFT JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP AS C (NOLOCK) ON C.ID_ACIONA = A.ID_ACIONA                                            
		WHERE 
			A.TIPOCANALDEEPCENT_ACIONAMENTO = 4                                                  
                                                  
		UNION ALL                                                   
                                                  
		SELECT                                                   
			A.*, A.ID_ACIONA AS IDCALL, B.PHONENUMBER, 4 AS TIPODISCAGEM, 1 AS TIPOATENDIMENTO, NULL AS TEMPOFALANDO,                                 
			NULL AS IDGRAVACAO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAINICIO, LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORAFIM,                                              
			NULL AS TEMPOTABULANDO, NULL AS TEMPOCHAMADA, NULL AS TEMPOESPERA, NULL AS DESLIGADOPOR, A.TIPOCANALDEEPCENT_ACIONAMENTO AS TIPOCANAL, D.TIPO_LIGACAO,                                                   
			LEFT(TRY_CONVERT(VARCHAR(50), TRY_CONVERT(TIME, A.DATA_ACIONA)), 8) AS HORA, NULL AS IDCALL_SINERGYTECH, NULL AS MAILING              
		FROM                                                   
			SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP AS A (NOLOCK)                                                  
			JOIN SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS C (NOLOCK) ON C.CONTRATO_FIN = A.CONTRATO_FIN                
			CROSS APPLY (
				SELECT TOP 1 
					RTRIM(LTRIM(B.DDD_TEL))+RTRIM(LTRIM(B.TEL_TEL)) AS PHONENUMBER                                                  
				FROM 
					SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP AS B (NOLOCK)                                                    
				WHERE 
					B.CPF_DEV = C.CPF_DEV AND LEN(B.TEL_TEL)>=9                                                  
				ORDER BY 
					B.POSSUIWHATSAPP_TEL, B.PERC_TEL DESC, B.COD_TEL DESC
			) AS B                                                  
			LEFT JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP AS D (NOLOCK) ON D.ID_ACIONA = A.ID_ACIONA  AND TIPO_LIGACAO = 2 /*AND TIPO_LIGACAO = 2 ACRESCENTADO NA OS 156136*/                                   
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
			SRC.DeepCenter.ACIONA_BRADESCO_SELECAO_REP AS A (NOLOCK)                                                  
			JOIN SRC.DeepCenter.TAB_IDLIGACAODISCADOR_ACIONA_BRADESCO_SELECAO_REP AS C (NOLOCK) ON C.ID_ACIONA = A.ID_ACIONA                                                    
			JOIN SRC.DeepCenter.TBL_RESULTADODISCAGEM_SINERGYTECH_BRADESCO_SELECAO_REP AS B (NOLOCK) ON C.IDCALL = B.IDCALL_SINERGYTECH
	) AS X 
 
 --select * from SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_REP
                                                    
                                                    
 /****************************************************** JUNÇÃO ***********************************************************/                                                 
                              
	IF OBJECT_ID ('SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP') IS NULL                                                    
	BEGIN                       
		SELECT 
			ROW_NUMBER() OVER(ORDER BY [DATA], HORA) AS ID,*                               
		INTO 
			SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP                                                   
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
			END AS IDAGEN
			,CASE 
				WHEN COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0) = 1 THEN RIGHT(REPLICATE('0', 14) + RTRIM(LTRIM(E.CPF_DEV)), 14)                                         
				ELSE RIGHT(REPLICATE('0', 11) + RTRIM(LTRIM(E.CPF_DEV)), 11) 
			END AS IDCUSTOMER
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
			,A.COD_ACIONAMENTO AS IDOCORRENCIA                             
			,IIF(A.CODACIONADEEPCENTER_ACIONAMENTO = 8202, IIF(A.TEMPOESPERA <= 15, 'NAO OUVIU RECADO HANG UP', 'VOICER HANG UP'),COALESCE(IIF(RTRIM(LTRIM(A.DESCRICAODEEPCENTER_ACIONAMENTO))='',NULL,A.DESCRICAODEEPCENTER_ACIONAMENTO), A.DESC_ACIONAMENTO)) AS DESCOCORRENCIA,                                        
			COALESCE(IIF(A.PHONENUMBER='0',NULL,A.PHONENUMBER), I.PHONENUMBER) AS PHONENUMBER
			,IIF(G.NOME_RECUP = 'OLOS WAY', 2, A.TIPODISCAGEM) AS TIPODISCAGEM                                          
			,IIF(G.NOME_RECUP = 'OLOS WAY', 1, A.TIPOATENDIMENTO) AS TIPOATENDIMENTO
			,0 AS ORIGEMTEL                                                    
			,A.TEMPOFALANDO                                                    
			,A.TEMPOTABULANDO                                                    
			,A.TEMPOCHAMADA                         
			,A.TEMPOESPERA
			,A.DESLIGADOPOR
			,CASE                     
				WHEN COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0) >= 2 THEN 0                                                     
				ELSE COALESCE(TRY_CONVERT(INT, E.COD_TIPESS),0)                                                     
			END AS IDPERFIL
			,3 AS SEGMENTOCANAL
			,CASE                              
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '3A52' THEN 6 -- OS168675                                          
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '2A52' THEN 23                                                  
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '4A53' THEN 24                                                  
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '7A51' THEN 25                                                  
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '8A51' THEN 26                                            
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '6A51' THEN 40 -- OS167390                                   
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '1A52' THEN 41 -- OS167390                                            
				WHEN E.COD_CLI = 11										   THEN 27                                 
				WHEN L.COD_EMPRESA = 'ABLG0000'							   THEN 6                                                  
				WHEN R.CPF_DEV IS NOT NULL								   THEN 6                                                  
				ELSE E.PORTFOLIODEEPCENTER_CLI                 
			END AS PORTFOLIO
			,CASE                                                  
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '3A52' THEN 39                                                  
				WHEN E.COD_CLI = 11 AND SUBSTRING(X.FILLER, 3, 5) = '2A52' THEN 40
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
			,CASE                                          
				WHEN E.COD_CLI IN (16,17) THEN SUBSTRING(K.CARTEIRA,PATINDEX('%[a-z,1-9]%',K.CARTEIRA),LEN(K.CARTEIRA ))                                          
				WHEN E.PORTFOLIODEEPCENTER_CLI = 7 THEN 'EAVM'                                          
				ELSE SUBSTRING(L.CARTEIRA,PATINDEX('%[A-Z,1-9]%',L.CARTEIRA),LEN(L.CARTEIRA))                                          
			END AS CARTEIRA
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
			E.PLANO_FIN AS PLANO,
			A.ID_ENQUETE, 
			A.ID_RESPOSTA
		FROM                              
			SRC.DeepCenter.TBL_JUNCAO_ACIONA_DISCADOR_REP AS A (NOLOCK)                                                    
			INNER JOIN SRC.DeepCenter.CAD_DEVF_BRADESCO_SELECAO_REP AS E (NOLOCK) ON E.CONTRATO_FIN = A.CONTRATO_FIN                                                    
			LEFT JOIN SRC.DeepCenter.AUX_DEVF_BRADESCO_SELECAO_REP AS F (NOLOCK) ON F.CONTRATO_FIN = E.CONTRATO_FIN                                                    
			INNER JOIN [SRC].DBO.CAD_RECUP AS G (NOLOCK) ON G.COD_RECUP = A.COD_RECUP                                                    
			LEFT JOIN SRC.DeepCenter.CAD_ACOP_AGREGACAO_BRADESCO_SELECAO_REP AS H (NOLOCK) ON H.CONTRATO_FIN = E.CONTRATO_FIN
			OUTER APPLY (
				SELECT 
					RTRIM(LTRIM(I.DDD_TEL))+RTRIM(LTRIM(I.TEL_TEL)) AS PHONENUMBER                                                  
				FROM 
					SRC.DeepCenter.CAD_DEVT_BRADESCO_SELECAO_REP AS I (NOLOCK)                               
				WHERE  
					(I.CPF_DEV = E.CPF_DEV AND I.TEL_TEL = A.TEL_TEL) 
			) AS I
			LEFT JOIN SRC.DeepCenter.AUX_BRADESCOBANCO_BRADESCO_SELECAO_REP AS L (NOLOCK) ON L.CONTRATO_FIN = E.CONTRATO_FIN
			OUTER APPLY( 
				SELECT TOP 1 
					COD_UF, 
					CIDADE_END 
				FROM 
					SRC.DeepCenter.CAD_DEVE_BRADESCO_SELECAO_REP AS P                                                     
				WHERE 
					P.CPF_DEV = E.CPF_DEV 
				ORDER BY 
					P.DTINCLUSAO_END, P.COD_END 
			) AS P
			LEFT JOIN [SRC].dbo.CAD_UF AS Q ON Q.COD_UF = P.COD_UF                                                  
			LEFT JOIN TBL_BRADESCO_PORTOLIO_35 AS R WITH (NOLOCK) ON R.CPF_DEV = E.CPF_DEV
			OUTER APPLY (SELECT TOP 1 DESCRIAO FROM AUX_CARTOESBRADESCO (NOLOCK) AS J WHERE J.CONTRATO_FIN = A.CONTRATO_FIN) AS J 
			OUTER APPLY (SELECT TOP 1 * FROM SRC.DeepCenter.AUX_BRADESCOLPTITULO_BRADESCO_SELECAO_REP (NOLOCK) AS K WHERE K.CONTRATO_FIN = A.CONTRATO_FIN) AS K
			LEFT JOIN AUX_CARTOESBRADESCO AS X WITH(NOLOCK) ON A.CONTRATO_FIN = X.CONTRATO_FIN
		) AS A 
		WHERE 
			RW = 1                                                  
	END                                                    
                                
	CREATE CLUSTERED INDEX CL_IX ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP (IDCALL, IDOCORRENCIA)                                
 
 --SELECT * FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP

 ------------------------------------------------------------------------------------------------------

	;WITH CTE AS                                  
	(                                  
	SELECT 
		 A.*, B.COD_RESULTADO AS CODACIONAMENTO_DEEP, B.COD_OCORRENCIA
		,C.COD_TIPODISCAGEMDEEPCENTER -- OS 171535
		,ROW_NUMBER () OVER (PARTITION BY A.IDCALL ORDER BY A.IDCALL) AS RW2    
		,0 AS IDMOTIVOINAD -- OS 171112
		,COALESCE(COD_TIPODISCAGEMDEEPCENTER,COD_CANALACIONAMENTO,1) as COD_CANALACIONAMENTO
		,1 AS idOrigemAtendimento
	FROM 
		SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_AUX_REP A                                
		LEFT JOIN [DEEPCENTER].CONFIG_ACIONAMENTO B ON A.IDOCORRENCIA = B.COD_ACIONAMENTO    
		LEFT JOIN DEEPCENTER.CONFIG_TIPODISCAGEM C ON C.COD_TIPODISCAGEMDISCADOR = A.TIPODISCAGEM
	)                                  
	SELECT 
		*                                  
	INTO 
		SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP                                  
	FROM 
		CTE                                  
	WHERE 
		RW2 = 1                               
 
 
	--select * from SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP                              
                                            
              
	CREATE CLUSTERED INDEX CL_IX ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP (ID) -- OS167056 
	CREATE NONCLUSTERED INDEX NO_IX_IDCALL ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP(IDCALL) -- OS168731
	CREATE NONCLUSTERED INDEX NO_IX ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP(IDOCORRENCIA, AGENTE) -- OS167056
	CREATE NONCLUSTERED INDEX NO_IX_CANALACIONAMENTO_IDCALL ON SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP(COD_CANALACIONAMENTO, TIPOATENDIMENTO)
	
	UPDATE A 
		SET COD_CANALACIONAMENTO = 1                
	FROM 
		SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP A                
	WHERE 
		A.TIPOATENDIMENTO = 0                
		AND A.COD_CANALACIONAMENTO = 17              
         
	--OS 171112        
	UPDATE B 
		SET IDMOTIVOINAD = A.COD_EXTERNO 
	FROM 
		TBL_RESPOSTAS_ENQUETES A        
		JOIN SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP AS B ON A.ID_ENQUETE = B.ID_ENQUETE AND A.ID_RESPOSTA = B.ID_RESPOSTA        
	WHERE 
		A.COD_EXTERNO <> 0
		
	DELETE FROM SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP WHERE IDOCORRENCIA = 2000016 AND AGENTE = 'OLOS' -- OS167056                                  

	UPDATE A 
		SET idOrigemAtendimento = 0
	FROM 
		SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP A                
	WHERE 
		COD_CANALACIONAMENTO in (1,9)

 --select * from SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP

----------------------------------------------------------------------------------------------------------------------
	IF OBJECT_ID('tempdb..#ATUALIZA_ID_OCORRENCIA') IS NOT NULL
	BEGIN
		DROP TABLE #ATUALIZA_ID_OCORRENCIA;
	END

	SELECT --TOP 10000 --PARA TESTE
	  COALESCE(A.COD_OCORRENCIA,A.IDOCORRENCIA) AS IDOCORRENCIA_CORRETO,
	  DATA,
	  HORAINICIO,
	  HORAFIM,
	  LEFT(A.CONTRATO,100) AS CONTRATO
	INTO
		#ATUALIZA_ID_OCORRENCIA
	FROM                                                    
	   SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP AS A
	   INNER JOIN DEEPCENTER.FINAL_ACIONAMENTO AS FA (NOLOCK) ON LEFT(A.CONTRATO,100) = FA.NUMCONTRACT														 
	WHERE
		COALESCE(A.COD_OCORRENCIA,A.IDOCORRENCIA) <> FA.IDOCORRENCIA
		AND FA.DTDATAREFERENCIA = A.DATA 
		AND FA.HRHORAINICIO = A.HORAINICIO
		AND FA.HRHORAFIM = A.HORAFIM
                                                    
	DECLARE @BLOCO INT = 5000, @STOP INT = 0 --,@QTD INT = 0 --PARA TESTE

	IF OBJECT_ID('tempdb..#ATT') IS NOT NULL
	BEGIN
		DROP TABLE #ATT
	END

	WHILE 1=1
	BEGIN
	--SELECIONA BLOCO
		SELECT TOP (@BLOCO)
			*
		INTO
			#ATT
		FROM
			#ATUALIZA_ID_OCORRENCIA		
		SELECT @STOP = COUNT(1) FROM #ATUALIZA_ID_OCORRENCIA	
		--PRINT 'Registros em #ATT: ' + CAST(@STOP AS VARCHAR(10))

	--VERIFICA SE TEM ATUALIZAÇÃO
		IF (@STOP <= 0)
		BEGIN
			BREAK;
		END

	--ATUALIZA
		UPDATE FA
		SET FA.IDOCORRENCIA = A.IDOCORRENCIA_CORRETO
		FROM                                                    
		   #ATT AS A   
		   INNER JOIN DEEPCENTER.FINAL_ACIONAMENTO AS FA (NOLOCK) ON A.CONTRATO = FA.NUMCONTRACT														 
		WHERE
			A.IDOCORRENCIA_CORRETO <> FA.IDOCORRENCIA
			AND FA.DTDATAREFERENCIA = A.DATA 
			AND FA.HRHORAINICIO = A.HORAINICIO
			AND FA.HRHORAFIM = A.HORAFIM

		SELECT @QTD += @@ROWCOUNT
		--PRINT 'Registros atualizados em FINAL_ACIONAMENTO: ' + CAST(@QTD AS VARCHAR(10)) --PARA TESTE
		--PRINT '@QTD DENTRO DO LOOP: ' + CAST(@QTD AS VARCHAR(10)) --PARA TESTE

	--LIMPA OS REGISTROS QUE ATUALIZARAM		
		DELETE A
		FROM
			#ATUALIZA_ID_OCORRENCIA AS A
			JOIN #ATT AS B ON A.CONTRATO = B.CONTRATO AND A.DATA = B.DATA AND A.HORAINICIO = B.HORAINICIO AND A.HORAFIM = B.HORAFIM
		--PRINT 'Registros deletados de #ATUALIZA_ID_OCORRENCIA: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) --PARA TESTE

		DELETE A
		FROM
			SRC.DeepCenter.TBL_JUNCAO_BRADESCO_CRMDAC_REP AS A
			JOIN #ATT AS B ON LEFT(A.CONTRATO,100) = B.CONTRATO AND A.DATA = B.DATA AND A.HORAINICIO = B.HORAINICIO AND A.HORAFIM = B.HORAFIM
		--PRINT 'Registros deletados de TBL_JUNCAO_BRADESCO_CRMDAC_REP: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) --PARA TESTE
		 
	--DROP A TABELA DE ATT
		DROP TABLE #ATT
	END
	--PRINT 'FORA DO LOOP @QTD: ' + CAST(@QTD AS VARCHAR(10)) --PARA TESTE
END TRY                                                    
BEGIN CATCH                                                    
	EXEC STP_LOG_ERRO 'ExecucaoDeepCenterBradescoComercialCrmDacRep_idocorrencia'                                                    
END CATCH
GO