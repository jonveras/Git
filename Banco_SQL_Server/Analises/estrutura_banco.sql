-- PARTE 1
-- Tabela temporária para armazenar informações das colunas das chaves estrangeiras
DECLARE @fkcolumns TABLE (
 name SYSNAME PRIMARY KEY,
 referencedtable SYSNAME,
 parenttable SYSNAME,
 referencedcolumns VARCHAR(MAX),
 parentcolumns VARCHAR(MAX)
)
 
-- Popula a tabela temporária com informações das FK
INSERT INTO @fkcolumns 
SELECT 
 a.name,
 b.name,
 c.name,
 -- Concatena as colunas referenciadas (tabela pai)
 STUFF((
 SELECT ',' + c.name 
 FROM sys.foreign_key_columns b 
 INNER JOIN sys.columns c ON b.referenced_object_id = c.object_id 
 AND b.referenced_column_id = c.column_id 
 WHERE a.object_id = b.constraint_object_id 
 FOR XML PATH('')
 ), 1, 1, '') AS parentcolumns,
 -- PARTE 2
 -- Concatena as colunas filhas (tabela filha)
 STUFF((
 SELECT ',' + c.name 
 FROM sys.foreign_key_columns b 
 INNER JOIN sys.columns c ON b.parent_object_id = c.object_id 
 AND b.parent_column_id = c.column_id 
 WHERE a.object_id = b.constraint_object_id 
 FOR XML PATH('')
 ), 1, 1, '') AS childcolumns 
FROM sys.foreign_keys a 
INNER JOIN sys.tables b ON a.referenced_object_id = b.object_id 
INNER JOIN sys.tables c ON a.parent_object_id = c.object_id;

-- Tabela temporária para armazenar referências das FK
DECLARE @fkrefs TABLE (
 referencedtable SYSNAME,
 parenttable SYSNAME,
 referencedcolumns VARCHAR(MAX),
 parentcolumns VARCHAR(MAX)
)