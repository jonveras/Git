CREATE PROCEDURE stpMigracaoFullLocaliza    
AS    
BEGIN TRY    
    
declare @obj varchar(100) = 'stpMigracaoFullLocaliza'    
declare @dt_ini datetime, @dt_fim datetime, @Qtd int = null    
    
-- SELEÇÕES LINKED SERVER ----------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpSelecaoMigracaoLocaliza    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'SELEÇÕES MIGRAÇÃO', @Dt_Ini, @Dt_Fim, @Qtd    
    
-- MIGRAÇÃO EMAIL ------------------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpMigracaoEmailLocaliza @Qtd output    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'MIGRAÇÃO EMAIL', @Dt_Ini, @Dt_Fim, @Qtd    
    
-- MIGRAÇÃO ENDEREÇO ------------------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpMigracaoEnderecoLocaliza @Qtd output    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'MIGRAÇÃO ENDEREÇO', @Dt_Ini, @Dt_Fim, @Qtd    
    
-- MIGRAÇÃO TELEFONE ------------------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpMigracaoTelefoneLocaliza @Qtd output    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'MIGRAÇÃO TELEFONE', @Dt_Ini, @Dt_Fim, @Qtd    
    
-- MIGRAÇÃO RECUP ACORDOS -------------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpMigracaoRecupAcordo @Qtd output    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'MIGRAÇÃO RECUP ACORDOS', @Dt_Ini, @Dt_Fim, @Qtd    
    
-- MIGRAÇÃO ACIONAMENTO ---------------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpMigracaoAcionaFullLocaliza 1, @Qtd output    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'MIGRAÇÃO ACIONAMENTO', @Dt_Ini, @Dt_Fim, @Qtd    
    
-- MIGRAÇÃO STCB ----------------------------------------------------------------------    
    
set @dt_ini = getdate()    
exec stpMigracaoStcbLocaliza @Qtd output    
set @dt_fim = getdate()    
exec stpLogTempoExecucao @obj, 'MIGRAÇÃO STCB', @Dt_Ini, @Dt_Fim, @Qtd    
    
end try    
begin catch    
 EXEC STP_LOG_ERRO 'stpMigracaoFullLocaliza'    
    
 SELECT      
    ERROR_NUMBER() AS ERRORNUMBER        
   ,ERROR_SEVERITY() AS ERRORSEVERITY        
   ,ERROR_STATE() AS ERRORSTATE        
   ,ERROR_PROCEDURE() AS ERRORPROCEDURE        
   ,ERROR_LINE() AS ERRORLINE        
   ,ERROR_MESSAGE() AS ERRORMESSAGE;      
end catch