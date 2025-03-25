DECLARE @sql NVARCHAR(MAX) = N''
DECLARE @db SYSNAME

-- Cursor para percorrer todos os bancos de dados
DECLARE db_cursor CURSOR FOR  
SELECT name FROM sys.databases 
WHERE state_desc = 'ONLINE' AND database_id > 4  -- Ignora bancos do sistema

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @db  

WHILE @@FETCH_STATUS = 0  
BEGIN  
    SET @sql = @sql + 
        'IF EXISTS (SELECT 1 FROM [' + @db + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''A'') 
        PRINT ''Tabela A encontrada no banco: ' + @db + ''';' + CHAR(13)
    
    FETCH NEXT FROM db_cursor INTO @db  
END  

CLOSE db_cursor  
DEALLOCATE db_cursor  

EXEC sp_executesql @sql