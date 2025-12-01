sp_helptext stpSelecaoMigracaoLocaliza

CREATE PROCEDURE stpSelecaoMigracaoLocaliza      
AS      
BEGIN TRY      
      
declare @obj varchar(100) = 'stpSelecaoMigracaoLocaliza'      
declare @dt_ini datetime, @dt_fim datetime, @Qtd int = null      
      
------------------------------------------------------- CONTRATOS ---------------------------------------------------------       
      
-------------- NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX --------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX;      
END;      
      
SELECT top 10        
 OBSERVACOES collate SQL_Latin1_General_CP1_CI_AS AS CONTRATO_ORIGINAL, A.*      
 INTO NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX      
FROM      
 [10.10.5.254].[NEO_ESPELHO].DBO.CONTRATOS AS  A      
WHERE       
 A.CONTRATANTE = 'Localiza Recupera'      
      
set @Qtd = @@ROWCOUNT      
      
CREATE CLUSTERED INDEX CL_IX ON NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX (IDCONTRATO) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX', @Dt_Ini, @Dt_Fim, @Qtd      
      
-------------- NEO_ESPELHO_CONTRATOS_LOCALIZA --------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_CONTRATOS_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_CONTRATOS_LOCALIZA;      
END;      
      
SELECT       
 * INTO NEO_ESPELHO_CONTRATOS_LOCALIZA      
FROM (      
 SELECT *, ROW_NUMBER() OVER(PARTITION BY CONTRATO_ORIGINAL ORDER BY IDCONTRATO DESC) AS RW      
 FROM NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX WITH(NOLOCK)      
) AS X      
WHERE X.RW = 1      
      
set @Qtd = @@ROWCOUNT      
      
CREATE CLUSTERED INDEX CL_IX ON NEO_ESPELHO_CONTRATOS_LOCALIZA (IDCONTRATO) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_CONTRATOS_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- DEVEDOR ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_DEVEDORES_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_DEVEDORES_LOCALIZA;      
END;      
      
SELECT      
 SUBSTRING(DEV.NUMEROCGCCPF,PATINDEX('%[1-9]%',DEV.NUMEROCGCCPF),14) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS CPF_DEV, DEV.*      
 INTO NEO_ESPELHO_DEVEDORES_LOCALIZA      
FROM       
 [10.10.5.254].[NEO_ESPELHO].DBO.DEVEDORES AS DEV WITH (NOLOCK)       
WHERE      
 EXISTS (SELECT * FROM NEO_ESPELHO_CONTRATOS_LOCALIZA_AUX AS A WHERE A.IDCONTRATO = DEV.IDCONTRATO)      
      
set @Qtd = @@ROWCOUNT      
      
CREATE CLUSTERED INDEX CL_IX ON NEO_ESPELHO_DEVEDORES_LOCALIZA (IDCONTRATO) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)      
CREATE NONCLUSTERED INDEX NON_IX ON NEO_ESPELHO_DEVEDORES_LOCALIZA (CPF_DEV) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_DEVEDORES_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- ACORDOS ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_ACORDOS_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_ACORDOS_LOCALIZA;      
END;      
      
SELECT       
 A.IDCONTRATO, A.NUMEROACORDO,       
 A.NUMEROACORDOCONTRATANTE COLLATE SQL_Latin1_General_CP1_CI_AS AS NUMEROACORDOCONTRATANTE,       
 A.IDFUNCIONARIO, A.FUNCIONARIO, B.CONTRATO_ORIGINAL      
 INTO NEO_ESPELHO_ACORDOS_LOCALIZA      
FROM       
 [10.10.5.254].[NEO_ESPELHO].DBO.ACORDOS  AS A WITH(NOLOCK)      
 JOIN NEO_ESPELHO_CONTRATOS_LOCALIZA AS B WITH(NOLOCK) ON A.IDCONTRATO = B.IDCONTRATO      
      
set @Qtd = @@ROWCOUNT      
      
CREATE CLUSTERED INDEX CL_IX ON NEO_ESPELHO_ACORDOS_LOCALIZA (IDCONTRATO) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_ACORDOS_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- JUNÇÃO DE CONTRATOS E CPFS ---------------------------------------------------------       
set @dt_ini = getdate()      
      
EXEC stpJuncaoContratosMigracaoLocaliza 1, @qtd output      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- EMAIL_DEVEDOR ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_EMAIL_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_EMAIL_LOCALIZA;      
END;      
      
SELECT * INTO NEO_ESPELHO_EMAIL_LOCALIZA      
FROM (      
 SELECT       
  A.CPF_DEV,      
  CAST(B.DESCRICAO AS VARCHAR(100)) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS DESCRICAO,         
  CAST(B.TIPO AS VARCHAR(100)) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS TIPO,       
  CAST(B.[STATUS] AS VARCHAR(100)) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS [STATUS],         
  B.PRIORITARIO, B.OBS, B.DATAINCLUSAO, B.LISTANEGRA,      
  ROW_NUMBER() OVER(PARTITION BY A.CPF_DEV, B.DESCRICAO ORDER BY A.CPF_DEV) AS RW      
 FROM       
  TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS A WITH(NOLOCK)      
  JOIN [10.10.5.254].[NEO_ESPELHO].DBO.EMAIL_DEVEDOR AS B WITH(NOLOCK) ON A.IDDEVEDOR = B.IDDEVEDOR      
) AS Y      
WHERE RW = 1      
      
set @Qtd = @@ROWCOUNT      
      
CREATE NONCLUSTERED INDEX NON_IX ON NEO_ESPELHO_EMAIL_LOCALIZA (CPF_DEV)      
CREATE NONCLUSTERED INDEX NON_IX2 ON NEO_ESPELHO_EMAIL_LOCALIZA (LISTANEGRA)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_EMAIL_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
--------------------------------------------------------- ENDERECO_DEVEDOR ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_ENDERECOS_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_ENDERECOS_LOCALIZA;      
END;      
      
SELECT       
 * INTO NEO_ESPELHO_ENDERECOS_LOCALIZA      
FROM (      
 SELECT       
  A.CPF_DEV,      
  CAST(B.ENDERECO AS VARCHAR(500)) collate SQL_Latin1_General_CP1_CI_AS AS ENDERECO,       
  CAST(B.NUMERO AS VARCHAR(100))  collate SQL_Latin1_General_CP1_CI_AS AS NUMERO,       
  CAST(B.COMPLEMENTO AS VARCHAR(100)) collate SQL_Latin1_General_CP1_CI_AS AS COMPLEMENTO,       
  CAST(B.BAIRRO AS VARCHAR(100))  collate SQL_Latin1_General_CP1_CI_AS AS BAIRRO,       
  CAST(B.CIDADE AS VARCHAR(100))  collate SQL_Latin1_General_CP1_CI_AS AS CIDADE,       
  CAST(B.UF AS VARCHAR(100))   collate SQL_Latin1_General_CP1_CI_AS AS UF,       
  CAST(B.CEP AS VARCHAR(14))   collate SQL_Latin1_General_CP1_CI_AS AS CEP,       
  CAST(B.TIPOENDERECO AS VARCHAR(14)) collate SQL_Latin1_General_CP1_CI_AS AS TIPOENDERECO,      
  B.RUIM, B.CORRESPONDENCIA,      
  B.DATAINCLUSAO,       
  ROW_NUMBER() OVER(PARTITION BY A.CPF_DEV, B.CEP, B.ENDERECO, B.NUMERO ORDER BY A.CPF_DEV) AS RW      
 FROM       
  TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS A WITH(NOLOCK)      
  JOIN [10.10.5.254].[NEO_ESPELHO].DBO.ENDERECO_DEVEDOR AS B WITH(NOLOCK) ON A.IDDEVEDOR = B.IDDEVEDOR      
) AS X      
WHERE RW = 1      
      
set @Qtd = @@ROWCOUNT      
      
CREATE NONCLUSTERED INDEX NON_IX ON NEO_ESPELHO_ENDERECOS_LOCALIZA (CPF_DEV)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_ENDERECOS_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
--------------------------------------------------------- TELEFONES ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_TELEFONES_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_TELEFONES_LOCALIZA;      
END;      
      
-- 1.108.697 / 7MIN      
SELECT       
 CPF_DEV,      
 CAST(TELEFONE AS VARCHAR(100))   collate SQL_Latin1_General_CP1_CI_AS AS TELEFONE,       
 CAST([TIPOTELEFONE] AS VARCHAR(100)) collate SQL_Latin1_General_CP1_CI_AS AS [TIPOTELEFONE],       
 CAST([STATUS] AS VARCHAR(100))   collate SQL_Latin1_General_CP1_CI_AS AS [STATUS],       
 CAST(RAMAL AS VARCHAR(100))       collate SQL_Latin1_General_CP1_CI_AS AS RAMAL,       
 CAST(OBS AS VARCHAR(100))       collate SQL_Latin1_General_CP1_CI_AS AS OBS,       
 PRIORITARIO, DATAINCLUSAO, LISTANEGRA, TIPO        
 INTO NEO_ESPELHO_TELEFONES_LOCALIZA      
FROM (      
  -- TELEFOENS DEVEDOR      
  SELECT *       
  FROM (      
   SELECT       
    A.CPF_DEV, B.TELEFONE, B.[TIPOTELEFONE], B.PRIORITARIO, B.[STATUS], B.RAMAL, B.OBS, B.DATAINCLUSAO, B.LISTANEGRA, 'DEVEDOR' AS TIPO,      
    ROW_NUMBER() OVER(PARTITION BY A.CPF_DEV, B.TELEFONE ORDER BY A.CPF_DEV) AS RW      
   FROM       
    TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS A WITH(NOLOCK)      
    JOIN [10.10.5.254].[NEO_ESPELHO].DBO.TELEFONES_DO_DEVEDOR AS B WITH(NOLOCK) ON A.IDDEVEDOR = B.IDDEVEDOR      
  ) AS X      
  WHERE RW = 1      
      
  UNION ALL      
      
  -- TELEFONES AVALISTAS      
  SELECT *       
  FROM (      
   SELECT       
    A.CPF_DEV, B.TELEFONE, B.TIPO AS [TIPOTELEFONE], NULL AS PRIORITARIO, NULL AS [STATUS], B.RAMAL, NULL AS OBS, NULL AS DATAINCLUSAO, NULL AS LISTANEGRA, 'AVALISTA' AS TIPO,      
    ROW_NUMBER() OVER(PARTITION BY A.CPF_DEV, B.TELEFONE ORDER BY A.CPF_DEV) AS RW      
   FROM       
    TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS A WITH(NOLOCK)      
    JOIN [10.10.5.254].[NEO_ESPELHO].DBO.TELEFONES_DO_AVALISTA AS B WITH(NOLOCK) ON A.IDCONTRATO = B.IDCONTRATO      
  ) AS Y      
  WHERE RW = 1      
      
) AS Z      
      
set @Qtd = @@ROWCOUNT      
      
CREATE NONCLUSTERED INDEX NON_IX ON NEO_ESPELHO_TELEFONES_LOCALIZA (CPF_DEV)      
CREATE NONCLUSTERED INDEX NON_IX2 ON NEO_ESPELHO_TELEFONES_LOCALIZA (LISTANEGRA)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_TELEFONES_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- FUNCIONARIOS  ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_RECUPS_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_RECUPS_LOCALIZA;      
END;      
      
SELECT       
 IDFUNCIONARIOS,       
 NOMEUSUARIO COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS NOMEUSUARIO ,       
 LOGONUSUARIO COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS LOGONUSUARIO       
 INTO NEO_ESPELHO_RECUPS_LOCALIZA       
FROM       
 [10.10.5.254].[NEO_ESPELHO].DBO.FUNCIONARIOS       
      
set @Qtd = @@ROWCOUNT      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_RECUPS_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- ACIONA ---------------------------------------------------------       
      
/* *********** obs.: PARA A SELEÇÃO DE DADOS DE ACIONAMENTOS BASTA EXECUTAR A PROCEDURE stpSelecaoMigracaoAcionaLocaliza *********** */      
set @dt_ini = getdate()      
exec stpSelecaoMigracaoAcionaLocaliza @Qtd output      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_ACIONA_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
------------------------------------------------------- HISTORICO_DE_AGENDAMENTOS  ---------------------------------------------------------       
      
set @dt_ini = getdate()      
IF OBJECT_ID('NEO_ESPELHO_HISTORICO_STCB_LOCALIZA') IS NOT NULL      
BEGIN      
 DROP TABLE NEO_ESPELHO_HISTORICO_STCB_LOCALIZA;      
END;      
      
SELECT       
 X.CONTRATO_ORIGINAL,       
 A.DESCRICAOAGENDAMENTO COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS AS DESCRICAOAGENDAMENTO,      
 A.DATAHORAMUDANCA,      
 A.IDCONTRATO,      
 B.PESO      
 INTO NEO_ESPELHO_HISTORICO_STCB_LOCALIZA      
FROM       
 [10.10.5.254].[NEO_ESPELHO].DBO.HISTORICO_DE_AGENDAMENTOS AS A WITH(NOLOCK)      
 JOIN AUXSRC.[DBO].[PESO_STCB_NEO] AS B ON A.[DESCRICAOAGENDAMENTO] COLLATE LATIN1_GENERAL_CI_AS = B.[DESCRIÇÃO]      
 JOIN AUXSRC.DBO.TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS X ON A.IDCONTRATO = X.IDCONTRATO       
      
set @Qtd = @@ROWCOUNT      
      
CREATE NONCLUSTERED INDEX NON_IX ON NEO_ESPELHO_HISTORICO_STCB_LOCALIZA (CONTRATO_ORIGINAL) INCLUDE(DESCRICAOAGENDAMENTO, PESO, DATAHORAMUDANCA)      
      
set @dt_fim = getdate()      
exec stpLogTempoExecucao @obj, 'NEO_ESPELHO_HISTORICO_STCB_LOCALIZA', @Dt_Ini, @Dt_Fim, @Qtd      
      
      
end try      
begin catch      
 EXEC STP_LOG_ERRO 'stpSelecaoMigracaoLocaliza'      
      
 SELECT        
    ERROR_NUMBER() AS ERRORNUMBER          
   ,ERROR_SEVERITY() AS ERRORSEVERITY          
   ,ERROR_STATE() AS ERRORSTATE          
   ,ERROR_PROCEDURE() AS ERRORPROCEDURE          
   ,ERROR_LINE() AS ERRORLINE          
   ,ERROR_MESSAGE() AS ERRORMESSAGE;        
end catch