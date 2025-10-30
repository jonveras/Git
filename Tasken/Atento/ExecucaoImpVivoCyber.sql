ALTER PROCEDURE ExecucaoImpVivoCyber        
AS         
BEGIN TRY        
	-----------------------------------------------------------        
	-- Passo 1 - Obter os CPR_IDs        
	-----------------------------------------------------------        
	IF OBJECT_ID('TEMPDB.DBO.#CPRID') IS NOT NULL        
	BEGIN        
		DROP TABLE #CPRID        
	END        
        
	SELECT CPR_ID, ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) AS QTD        
	INTO #CPRID        
	FROM SRC.DBO.CAD_DEVT_STAGE_PROCESS         
	GROUP BY CPR_ID        
        
	DECLARE 
		@I INT = 1,        
		@TOTAL INT,        
		@CPR_ID INT,        
		@CPR_ATUALIZA_STATUS_TELEFONES VARCHAR(10),        
		@CPR_ATUALIZA_PERCENTUAIS_TELEFONES VARCHAR(10),        
		@CPR_COD_ORIGEM VARCHAR(10),        
		@CPR_COD_TIPO VARCHAR(10),        
		@CPR_PERCENTUAL_LOC_TELEFONE VARCHAR(10),        
		@VLRINI INT = 0,        
		@VLRFIM INT = 50000;        
        
	-- Pega a quantidade total de registros        
	SELECT @TOTAL = COUNT(*) FROM #CPRID;        
      
	IF @TOTAL <= 0      
	BEGIN      
		PRINT 'SEM ATUALIZAÇÕES PARA REALIZAR';      
		RETURN;      
	END      
        
	-----------------------------------------------------------        
	-- Passo 2 - Obter as configurações específicas do CPR_ID        
	-----------------------------------------------------------        
	WHILE @I <= @TOTAL        
	BEGIN        
		-- Pega o CPR_ID correspondente à linha atual        
		SELECT @CPR_ID = CPR_ID        
		FROM #CPRID        
		WHERE QTD = @I;        
        
		SELECT         
			@CPR_ATUALIZA_STATUS_TELEFONES = MAX(CASE WHEN RTRIM(LTRIM(CCP_NOME_CAMPO)) = 'CPR_ATUALIZA_STATUS_TELEFONES' THEN ICP_VALOR_CONFIGURADO END),        
			@CPR_ATUALIZA_PERCENTUAIS_TELEFONES = MAX(CASE WHEN RTRIM(LTRIM(CCP_NOME_CAMPO)) = 'CPR_ATUALIZA_PERCENTUAIS_TELEFONES' THEN ICP_VALOR_CONFIGURADO END),        
			@CPR_COD_ORIGEM = MAX(CASE WHEN RTRIM(LTRIM(CCP_NOME_CAMPO)) = 'CPR_COD_ORIGEM' THEN ICP_VALOR_CONFIGURADO END),        
			@CPR_COD_TIPO = MAX(CASE WHEN RTRIM(LTRIM(CCP_NOME_CAMPO)) = 'CPR_COD_TIPO' THEN ICP_VALOR_CONFIGURADO END),        
			@CPR_PERCENTUAL_LOC_TELEFONE = MAX(CASE WHEN RTRIM(LTRIM(CCP_NOME_CAMPO)) = 'CPR_PERCENTUAL_LOC_TELEFONE' THEN ICP_VALOR_CONFIGURADO END)        
		FROM         
			SMARTWAYPROCESS_ATENTO.DBO.SPR_TBL_CAD_CAMPOS_CONFIGURACAO_PROCESSAMENTO A        
			LEFT JOIN SMARTWAYPROCESS_ATENTO.DBO.SPR_TBL_CAD_EXIBE_CONFIGURACAO_PROCESSAMENTO B ON A.CCP_ID = B.ECP_CCP_ID        
			LEFT JOIN SMARTWAYPROCESS_ATENTO.DBO.SPR_TBL_CAD_CONFIGURACAO_PROCESSAMENTO C ON B.ECP_PRC_ID = C.CPR_PRC_ID        
			LEFT JOIN SMARTWAYPROCESS_ATENTO.DBO.SPR_TBL_CAD_ITENS_CONFIGURACAO_PROCESSAMENTO D ON D.ICP_ECP_ID = B.ECP_ID AND D.ICP_CPR_ID = C.CPR_ID        
		WHERE         
			C.CPR_ID = @CPR_ID;        
        
		-----------------------------------------------------------        
		-- Passo 3 - Filtrar os casos conforme as configs 
		-----------------------------------------------------------
		WHILE (SELECT TOP 1 1 FROM SRC.DBO.CAD_DEVT_STAGE_PROCESS WHERE CPR_ID = @CPR_ID) = 1
		BEGIN
			IF OBJECT_ID('SRC.DBO.CAD_DEVT_STAGE_PROCESS_FINAL') IS NOT NULL        
			BEGIN        
				DROP TABLE SRC.DBO.CAD_DEVT_STAGE_PROCESS_FINAL        
			END 
			
			IF DATEPART(HOUR,GETDATE()) BETWEEN 0 AND 6
			BEGIN
				RETURN;
			END
         
			SELECT          
				B.CPF_DEV,        
				B.COD_TEL,        
				A.DDD_TEL,        
				A.TEL_TEL,        
				A.PERC_TEL,        
				A.COD_TIPO,        
				A.STATUS_TEL,        
				A.COD_ORIGEM,        
				A.BLOQUEIO_TEL,        
				A.ID,        
				A.DTNEGATIV_TEL,        
				A.ORDEMPRIORIDADE_TEL,        
				A.OBSIMP_TEL,        
				A.OBS_TEL,        
				A.DTCONFIRM_TEL        
			INTO        
				SRC.DBO.CAD_DEVT_STAGE_PROCESS_FINAL        
			FROM        
				SRC.DBO.CAD_DEVT_STAGE_PROCESS AS A  WITH (NOLOCK) --STAGE        
				JOIN SRC.DBO.CAD_DEV AS X WITH (NOLOCK) ON X.CPF_DEV = A.CPF_DEV        
				JOIN SRC.DBO.CAD_DEVT AS B WITH (NOLOCK, INDEX(NON_IX_5)) ON B.CPF_DEV = X.CPF_DEV        
				AND B.DDD_TEL = A.DDD_TEL         
				AND A.TEL_TEL = B.TEL_TEL        
			WHERE (         
				(@CPR_ATUALIZA_STATUS_TELEFONES = '1' AND (A.STATUS_TEL <> B.STATUS_TEL OR A.BLOQUEIO_TEL <> B.BLOQUEIO_TEL))        
				OR         
				(@CPR_ATUALIZA_PERCENTUAIS_TELEFONES = '1' AND @CPR_PERCENTUAL_LOC_TELEFONE <> COALESCE(B.PERC_TEL,-1))         
				OR        
				(@CPR_COD_ORIGEM  <> '' AND @CPR_COD_ORIGEM <> COALESCE(B.COD_ORIGEM,-1) OR A.COD_ORIGEM IS NOT NULL AND A.COD_ORIGEM <> B.COD_ORIGEM)         
				OR        
				(@CPR_COD_TIPO  <> '' AND @CPR_COD_TIPO <> COALESCE(B.COD_TIPO,-1) OR A.COD_TIPO IS NOT NULL AND A.COD_TIPO <> B.COD_TIPO)         
				)        
				AND A.CPR_ID = @CPR_ID
				AND A.ID BETWEEN @VLRINI AND @VLRFIM;        
        
			-----------------------------------------------------------        
			-- Passo 4 - Atualizar os casos e deleta da stage    
			-----------------------------------------------------------                
			UPDATE B          
			SET        
				B.STATUS_TEL           = A.STATUS_TEL         ,        
				B.BLOQUEIO_TEL         = A.BLOQUEIO_TEL       ,        
				B.DTNEGATIV_TEL        = A.DTNEGATIV_TEL      ,        
				B.PERC_TEL             = A.PERC_TEL           ,        
				B.COD_ORIGEM           = A.COD_ORIGEM         ,        
				B.COD_TIPO             = A.COD_TIPO           ,        
				B.ORDEMPRIORIDADE_TEL  = A.ORDEMPRIORIDADE_TEL,        
				B.OBSIMP_TEL           = A.OBSIMP_TEL         ,        
				B.OBS_TEL              = A.OBS_TEL            ,        
				B.DTCONFIRM_TEL        = A.DTCONFIRM_TEL        
			FROM        
				SRC.DBO.CAD_DEVT_STAGE_PROCESS_FINAL AS A        
				JOIN SRC.DBO.CAD_DEVT AS B (NOLOCK) ON B.CPF_DEV = A.CPF_DEV AND A.COD_TEL = B.COD_TEL
   
			DELETE FROM SRC.DBO.CAD_DEVT_STAGE_PROCESS
			WHERE ID BETWEEN @VLRINI AND @VLRFIM AND CPR_ID = @CPR_ID
        
			IF @@ROWCOUNT <= 0         
			BEGIN
				BREAK;    
			END
        
			SET @VLRINI = @VLRFIM + 1        
			SET @VLRFIM = @VLRFIM + 5000
		END
		-----------------------------------------------------------        
		-- Próximo CPR_ID        
		-----------------------------------------------------------        
		SET @I += 1;        
	END             
END TRY        
BEGIN CATCH        
	EXEC STP_LOG_ERRO 'ExecucaoImpVivoCyber'     
	PRINT 'ERRO AS '+CAST(GETDATE() AS VARCHAR(MAX))+', CONSULTAR TABELA TBL_LOG_JOB'
END CATCH