SELECT
    [name] AS Tabela,

    'EXEC sys.sp_cdc_disable_table
    @source_schema = N''dbo'',
    @source_name = N''' + [name] + ''',
    @capture_instance = N''DBO_' + [name] + ''';' AS Script_Desabilitar,

    'EXEC sys.sp_cdc_enable_table
    @source_schema = N''dbo'',
    @source_name = N''' + [name] + ''',
    @role_name = NULL;' AS Script_Habilitar
INTO
	ANALISETI.DBO.CDC_TABELAS
FROM sys.tables
WHERE is_tracked_by_cdc = 1