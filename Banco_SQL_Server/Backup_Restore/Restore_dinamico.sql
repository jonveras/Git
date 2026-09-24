USE [master];
GO

/* ============================================================
   CONFIGURAÇÕES
   ============================================================ */

DECLARE @CaminhoBackup NVARCHAR(500) =
N'\\192.168.9.146\srv-arch03\SRV-SOMADB\BACKUP_MSSQL\SRV-SOMADB\LINX_CB\FULL\SRV-SOMADB_LINX_CB_FULL_20251106_163000.BAK';

DECLARE @NomeBanco SYSNAME = N'MF_LINX';

DECLARE @PastaData NVARCHAR(500) = N'H:\MSSQL\DATA\';
DECLARE @PastaLog  NVARCHAR(500) = N'H:\MSSQL\LOG\';


/* ============================================================
   TABELA PARA RECEBER O RESTORE FILELISTONLY
   ============================================================ */

IF OBJECT_ID('tempdb..#FileList') IS NOT NULL
    DROP TABLE #FileList;

CREATE TABLE #FileList
(
    LogicalName           NVARCHAR(128),
    PhysicalName          NVARCHAR(260),
    [Type]                CHAR(1),
    FileGroupName         NVARCHAR(128),
    [Size]                NUMERIC(20,0),
    MaxSize               NUMERIC(20,0),
    FileId                BIGINT,
    CreateLSN             NUMERIC(25,0),
    DropLSN               NUMERIC(25,0),
    UniqueId              UNIQUEIDENTIFIER,
    ReadOnlyLSN           NUMERIC(25,0),
    ReadWriteLSN          NUMERIC(25,0),
    BackupSizeInBytes     BIGINT,
    SourceBlockSize       INT,
    FileGroupId           INT,
    LogGroupGUID          UNIQUEIDENTIFIER,
    DifferentialBaseLSN   NUMERIC(25,0),
    DifferentialBaseGUID  UNIQUEIDENTIFIER,
    IsReadOnly            BIT,
    IsPresent             BIT,
    TDEThumbprint         VARBINARY(32),
    SnapshotURL           NVARCHAR(360)
);


/* ============================================================
   LÊ OS ARQUIVOS DO BACKUP
   ============================================================ */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
RESTORE FILELISTONLY
FROM DISK = ''' +
REPLACE(@CaminhoBackup, '''', '''''') +
N''';';


INSERT INTO #FileList
EXEC (@SQL);


/* ============================================================
   VISUALIZA OS ARQUIVOS ENCONTRADOS
   ============================================================ */

SELECT
    FileId,
    LogicalName,
    PhysicalName,
    [Type],
    FileGroupName,
    CAST([Size] / 1024.0 / 1024.0 AS DECIMAL(18,2)) AS SizeMB
FROM #FileList
ORDER BY FileId;


/* ============================================================
   GERA O SCRIPT DE RESTORE
   ============================================================ */

DECLARE @Restore NVARCHAR(MAX);

SET @Restore =
    N'USE [master]' + CHAR(13) + CHAR(10) +
    N'RESTORE DATABASE [' + @NomeBanco + N']' + CHAR(13) + CHAR(10) +
    N'FROM DISK = N''' +
    REPLACE(@CaminhoBackup, '''', '''''') +
    N'''' + CHAR(13) + CHAR(10) +
    N'WITH' + CHAR(13) + CHAR(10);


/* ============================================================
   ADICIONA OS MOVE
   ============================================================ */

SELECT @Restore = @Restore +

    N'    MOVE N''' +
    REPLACE(LogicalName, '''', '''''') +
    N''' TO N''' +

    CASE

        /* =========================
           LOG
           ========================= */

        WHEN [Type] = 'L' THEN

            @PastaLog +
            @NomeBanco +
            CASE
                WHEN COUNT(*) OVER (PARTITION BY [Type]) = 1
                    THEN N'_LOG.LDF'''
                ELSE
                    N'_LOG_' +
                    CAST(
                        ROW_NUMBER() OVER (
                            PARTITION BY [Type]
                            ORDER BY FileId
                        ) AS NVARCHAR(10)
                    ) +
                    N'.LDF'''
            END

        /* =========================
           DADOS
           ========================= */

        ELSE

            @PastaData +
            @NomeBanco +

            CASE

                WHEN ROW_NUMBER() OVER (
                    PARTITION BY [Type]
                    ORDER BY FileId
                ) = 1

                THEN N'.MDF'''

                ELSE

                    N'_' +
                    CAST(
                        ROW_NUMBER() OVER (
                            PARTITION BY [Type]
                            ORDER BY FileId
                        ) AS NVARCHAR(10)
                    ) +
                    N'.NDF'''

            END

    END +

    N',' + CHAR(13) + CHAR(10)

FROM #FileList
ORDER BY FileId;


/* ============================================================
   REMOVE A ÚLTIMA VÍRGULA
   ============================================================ */

--SET @Restore =
--    LEFT(
--        @Restore,
--        LEN(@Restore) - 3
--    );


/* ============================================================
   FINALIZA O SCRIPT
   ============================================================ */

SET @Restore = @Restore +
    CHAR(13) + CHAR(10) +
    N'    RECOVERY,' + CHAR(13) + CHAR(10) +
    N'    STATS = 5' + CHAR(13) + CHAR(10) +
    N'GO';


/* ============================================================
   EXIBE O SCRIPT
   ============================================================ */

SELECT @Restore AS [SCRIPT_RESTORE];