CREATE PROCEDURE stpSelecaoMigracaoAcionaLocaliza(    
 @qtdSelecao int output    
)    
AS    
    
declare @obj varchar(100) = 'stpSelecaoMigracaoAcionaLocaliza'    
declare @dt_ini datetime, @dt_fim datetime, @Qtd int = null    
    
IF OBJECT_ID('NEO_ESPELHO_ACIONA_LOCALIZA') IS NOT NULL    
BEGIN    
 DROP TABLE NEO_ESPELHO_ACIONA_LOCALIZA;    
END;    
    
set @dt_ini = getdate()    
SELECT     
 A.CONTRATO_ORIGINAL,     
 Z.IDCONTRATO,    
 Z.DATAHORAANDAMENTO,    
 Z.NUMEROTELEFONE COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS as NUMEROTELEFONE ,    
 Z.IDENTIFICADORRESPOSTA,    
 Z.DESCRICAORESPOSTA COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS as DESCRICAORESPOSTA,    
 Z.DESCRICAOANDAMENTO COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS as DESCRICAOANDAMENTO,    
 Z.NOMEUSUARIO COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS as NOMEUSUARIO,    
 Z.RECEPTIVO    
 INTO NEO_ESPELHO_ACIONA_LOCALIZA    
FROM     
 TBL_CONTRATOS_JUNCAO_SRC_NEO_LOCALIZA AS A WITH (NOLOCK)    
    JOIN [10.10.5.254].[NEO_ESPELHO].DBO.ANDAMENTO_DA_COBRANCA AS Z (NOLOCK) ON Z.IDCONTRATO = A.IDCONTRATO    
    
set @Qtd = @@rowcount    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'seleção', @Dt_Ini, @Dt_Fim, @Qtd    
    
set @qtdSelecao = @Qtd    
    
-----------------------------------------------------------------------------------    
    
set @Qtd = null    
set @dt_ini = getdate()    
ALTER TABLE AUXSRC.[DBO].NEO_ESPELHO_ACIONA_LOCALIZA ADD ID INT IDENTITY(1,1)    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'add column id', @Dt_Ini, @Dt_Fim, @Qtd    
    
-----------------------------------------------------------------------------------    
    
set @Qtd = null    
set @dt_ini = getdate()    
CREATE CLUSTERED INDEX CL_IX ON AUXSRC.[DBO].NEO_ESPELHO_ACIONA_LOCALIZA  (ID) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)    
CREATE NONCLUSTERED INDEX non_IX ON AUXSRC.[DBO].NEO_ESPELHO_ACIONA_LOCALIZA  (CONTRATO_ORIGINAL) WITH (DATA_COMPRESSION = PAGE, ONLINE = ON)    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'create indices', @Dt_Ini, @Dt_Fim, @Qtd 