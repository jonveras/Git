WITH CTE_Duplicados AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY criado_em DESC) AS rn
    FROM clientes
)
DELETE c
FROM clientes c
JOIN CTE_Duplicados d ON c.id = d.id
WHERE d.rn > 1;
