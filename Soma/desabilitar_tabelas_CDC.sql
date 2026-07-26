SELECT
    [name] AS Tabela,

    'EXEC sys.sp_cdc_disable_table
    @source_schema = N''dbo'',
    @source_name = N''' + [name] + ''',
    @capture_instance = N''' + [name] + ''';' AS Script_Desabilitar,

    'EXEC sys.sp_cdc_enable_table
    @source_schema = N''dbo'',
    @source_name = N''' + [name] + ''',
    @role_name = NULL;' AS Script_Habilitar

FROM sys.tables
WHERE is_tracked_by_cdc = 1
ORDER BY [name];