DECLARE @cpu_count INT;

SELECT @cpu_count = COUNT(*) 
FROM sys.dm_os_schedulers 
WHERE status = 'VISIBLE ONLINE';

-- Obter configuração atual do MAXDOP
DECLARE @current_maxdop INT;

SELECT @current_maxdop = CAST(value_in_use AS INT)
FROM sys.configurations
WHERE name = 'max degree of parallelism';

-- Determinar valor recomendado com base na quantidade de CPUs
DECLARE @recommended_maxdop INT;

IF @cpu_count <= 4
    SET @recommended_maxdop = @cpu_count; -- Usa tudo se até 4 CPUs
ELSE IF @cpu_count <= 8
    SET @recommended_maxdop = 4;
ELSE IF @cpu_count <= 16
    SET @recommended_maxdop = 4;
ELSE
    SET @recommended_maxdop = 8;

-- Resultado
SELECT 
    @cpu_count AS Logical_CPU_Count,
    @current_maxdop AS Current_MAXDOP,
    @recommended_maxdop AS Recommended_MAXDOP,
    CASE 
        WHEN @current_maxdop = 0 THEN ' Está usando todos os núcleos (MAXDOP = 0) – pode causar gargalo de CPU'
        WHEN @current_maxdop > @recommended_maxdop THEN 'MAXDOP maior que o recomendado – pode causar sobrecarga de paralelismo'
        WHEN @current_maxdop < @recommended_maxdop THEN 'MAXDOP menor que o ideal – possível subutilização de CPU'
        ELSE 'MAXDOP está adequado'
    END AS Analysis