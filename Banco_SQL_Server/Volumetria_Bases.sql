DECLARE @t TABLE (
    DatabaseName sysname,
    TotalSizeMB DECIMAL(18,2),
    UsedSizeMB DECIMAL(18,2),
    FreeSpaceMB DECIMAL(18,2)
);

INSERT INTO @t
EXEC sp_MSforeachdb '
USE [?];
SELECT
    DB_NAME() AS DatabaseName,
    CAST(SUM(size) / 128.0 AS DECIMAL(18,2)) AS TotalSizeMB,
    CAST(SUM(FILEPROPERTY(name, ''SpaceUsed'')) / 128.0 AS DECIMAL(18,2)) AS UsedSizeMB,
    CAST((SUM(size) - SUM(FILEPROPERTY(name, ''SpaceUsed''))) / 128.0 AS DECIMAL(18,2)) AS FreeSpaceMB
FROM sys.database_files
WHERE type_desc = ''ROWS'';
';

SELECT *
FROM @t
ORDER BY TotalSizeMB DESC;