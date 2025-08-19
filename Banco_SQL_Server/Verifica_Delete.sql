-- Troque 'MinhaTabelaPai' pelo nome da tabela que você vai deletar
DECLARE @TabelaPai SYSNAME = 'cad_devf';

;WITH RecursiveFKs AS
(
    -- 1º nível: todas as tabelas que têm FK com ON DELETE CASCADE apontando para a tabela pai
    SELECT  
        fk.name AS ConstraintName,
        OBJECT_NAME(fk.parent_object_id) AS TabelaFilha,
        OBJECT_NAME(fk.referenced_object_id) AS TabelaPai,
        delete_referential_action_desc AS DeleteAction,
        1 AS Nivel
    FROM sys.foreign_keys fk
    WHERE fk.delete_referential_action_desc = 'CASCADE'
      AND OBJECT_NAME(fk.referenced_object_id) = @TabelaPai

    UNION ALL

    -- Recursividade: pega as tabelas filhas que também são pai de outras
    SELECT  
        fk.name AS ConstraintName,
        OBJECT_NAME(fk.parent_object_id) AS TabelaFilha,
        OBJECT_NAME(fk.referenced_object_id) AS TabelaPai,
        fk.delete_referential_action_desc,
        r.Nivel + 1
    FROM sys.foreign_keys fk
    INNER JOIN RecursiveFKs r
        ON OBJECT_NAME(fk.referenced_object_id) = r.TabelaFilha
    WHERE fk.delete_referential_action_desc = 'CASCADE'
)
SELECT 
    r.Nivel,
    r.TabelaPai,
    r.TabelaFilha,
    r.ConstraintName,
    r.DeleteAction,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM sys.triggers t
            INNER JOIN sys.tables tb ON t.parent_id = tb.object_id
            WHERE tb.name = r.TabelaFilha
              AND t.is_disabled = 0
              AND (t.type_desc LIKE '%DELETE%' OR t.is_instead_of_trigger = 1)
        ) THEN 'SIM'
        ELSE 'NÃO'
    END AS TemTriggerDelete
FROM RecursiveFKs r
ORDER BY r.Nivel, r.TabelaPai, r.TabelaFilha;
