SELECT
    DB_NAME() AS [DatabaseName],
    name AS FileName,
    CAST(size / 128.0 AS DECIMAL(10,2)) AS TamanhoMB,
    CAST(size / 128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) / 128.0 AS DECIMAL(10,2)) AS EspacoLivreMB,
    CAST(
        (size / 128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) / 128.0)
        / (size / 128.0) * 100.0 
    AS DECIMAL(5,2)) AS PorcentagemEspacoLivre
FROM sys.database_files
WHERE type_desc = 'ROWS';