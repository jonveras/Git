--HABILITA CDC
EXEC sp_cdc_enable_db
GO

--CRIA OS JOBS DE CDC
EXEC sp_cdc_add_job 'CAPTURE' --Criar o job para capturar os dados do CDC
GO
 
EXEC sp_cdc_add_job 'CLEANUP' --Criar o job para rotina de limpeza dos dados do CDC
GO

-- Habilitar CDC em tabelas
EXEC sys.sp_cdc_enable_table 
	@source_schema = N'dbo', 
	@source_name   = N'tabela', 
	@role_name     = NULL 
GO

-- Desabilitar o CDC em tabela
EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name = N'tabela',
    @capture_instance = N'dbo_tabela';

-- Desabilitar o CDC
EXEC sp_cdc_disable_db
GO

-- Verificar a tabela que guarda os dados
select top 100 * from cdc.dbo_nomedatabela_CT
