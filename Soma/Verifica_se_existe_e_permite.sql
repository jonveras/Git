DECLARE @Banco SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'
  AND database_id > 4; -- ignora master, tempdb, model e msdb

OPEN db_cursor;

FETCH NEXT FROM db_cursor INTO @Banco;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
    USE ' + QUOTENAME(@Banco) + N';

    IF EXISTS (
        SELECT 1
        FROM sys.objects
        WHERE object_id = OBJECT_ID(N''dbo.lx_gera_nfe_sefaz_4_00_linx'')
          AND type = ''P''
    )
    BEGIN

        GRANT EXECUTE ON OBJECT::dbo.lx_gera_nfe_sefaz_4_00_linx
        TO [animale\maicon.santana];

        PRINT ''Permissão concedida no banco: ' + REPLACE(@Banco, '''', '''''') + N''';
    END;
    ';

    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        PRINT 'ERRO no banco ' + @Banco + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @Banco;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;