SET NOCOUNT ON;

-- Declaração de variáveis
DECLARE @DatabaseDestino VARCHAR(8000),
        @Ds_Caminho_StandyBy VARCHAR(8000),
        @Ds_Pasta_Log VARCHAR(8000),
        @Nm_Arquivo_Log VARCHAR(8000),
        @Ds_Caminho_Backup_Full VARCHAR(8000),
        @Ds_Caminho_Backup_Diff VARCHAR(8000),
        @Ds_Extensao_Backup_Log VARCHAR(8000),
        @ComandoBackupLog VARCHAR(8000),
        @DatabaseOrigem VARCHAR(8000);

-- Parâmetros
SELECT
    @DatabaseOrigem = 'TESTE',
    @DatabaseDestino = 'TESTE_TESTE',
    @Ds_Caminho_Backup_Full = 'D:\JONATHAN\Backup\Full\TESTE_backup_2025_04_17_122010_4203855.bak',
    @Ds_Caminho_Backup_Diff = 'D:\JONATHAN\Backup\Diff\TESTE_backup_2025_04_17_130751_6167136.bak',
    @Ds_Caminho_StandyBy = NULL,
    @Ds_Extensao_Backup_Log = '.trn',
    @Ds_Pasta_Log = 'D:\JONATHAN\Backup\Log\';

-- Lista de arquivos .trn
IF OBJECT_ID('tempdb..#Lista_Arquivos_Log') IS NOT NULL DROP TABLE #Lista_Arquivos_Log;

CREATE TABLE #Lista_Arquivos_Log (
    subdirectory VARCHAR(500),
    depth TINYINT,
    [file] TINYINT
);

INSERT INTO #Lista_Arquivos_Log(subdirectory, depth, [file])
EXEC master.dbo.xp_dirtree @Ds_Pasta_Log, 1, 1;

DELETE FROM #Lista_Arquivos_Log
WHERE RIGHT(subdirectory, LEN(@Ds_Extensao_Backup_Log)) <> @Ds_Extensao_Backup_Log;

-- Cabeçalhos dos backups
IF OBJECT_ID('tempdb..#BackupHeader') IS NOT NULL DROP TABLE #BackupHeader;

CREATE TABLE #BackupHeader (
    BackupName NVARCHAR(128),
    BackupDescription NVARCHAR(255),
    BackupType SMALLINT,
    ExpirationDate DATETIME,
    Compressed BIT,
    Position SMALLINT,
    DeviceType TINYINT,
    UserName NVARCHAR(128),
    ServerName NVARCHAR(128),
    DatabaseName NVARCHAR(128),
    DatabaseVersion INT,
    DatabaseCreationDate DATETIME,
    BackupSize BIGINT,
    FirstLSN NUMERIC(25,0),
    LastLSN NUMERIC(25,0),
    CheckpointLSN NUMERIC(25,0),
    DatabaseBackupLSN NUMERIC(25,0),
    BackupStartDate DATETIME,
    BackupFinishDate DATETIME,
    SortOrder SMALLINT,
    CodePage SMALLINT,
    UnicodeLocaleId INT,
    UnicodeComparisonStyle INT,
    CompatibilityLevel TINYINT,
    SoftwareVendorId INT,
    SoftwareVersionMajor INT,
    SoftwareVersionMinor INT,
    SoftwareVersionBuild INT,
    MachineName NVARCHAR(128),
    Flags INT,
    BindingID UNIQUEIDENTIFIER,
    RecoveryForkID UNIQUEIDENTIFIER,
    Collation NVARCHAR(128),
    FamilyGUID UNIQUEIDENTIFIER,
    HasBulkLoggedData BIT,
    IsSnapshot BIT,
    IsReadOnly BIT,
    IsSingleUser BIT,
    HasBackupChecksums BIT,
    IsDamaged BIT,
    BeginsLogChain BIT,
    HasIncompleteMetaData BIT,
    IsForceOffline BIT,
    IsCopyOnly BIT,
    FirstRecoveryForkID UNIQUEIDENTIFIER,
    ForkPointLSN NUMERIC(25,0),
    RecoveryModel NVARCHAR(60),
    DifferentialBaseLSN NUMERIC(25,0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    BackupTypeDescription NVARCHAR(60),
    BackupSetGUID UNIQUEIDENTIFIER,
    CompressedBackupSize BIGINT,
    Containment TINYINT,
    KeyAlgorithm NVARCHAR(32),
    EncryptorThumbprint VARBINARY(20),
    EncryptorType NVARCHAR(32),
    BackupEncryptionOption NVARCHAR(128),
    EncryptorName NVARCHAR(128),
    EncryptionAlgorithmName NVARCHAR(128)
);

-- Backup Full
INSERT INTO #BackupHeader
EXEC('RESTORE HEADERONLY FROM DISK = ''' + @Ds_Caminho_Backup_Full + '''');

-- Backup Diferencial
IF @Ds_Caminho_Backup_Diff IS NOT NULL
BEGIN
    INSERT INTO #BackupHeader
    EXEC('RESTORE HEADERONLY FROM DISK = ''' + @Ds_Caminho_Backup_Diff + '''');
END

-- Cabeçalhos dos arquivos de LOG
IF OBJECT_ID('tempdb..#BackupHeaderLog') IS NOT NULL DROP TABLE #BackupHeaderLog;

SELECT IDENTITY(INT, 1, 1) AS ID, subdirectory
INTO #BackupHeaderLog
FROM #Lista_Arquivos_Log;

WHILE EXISTS (SELECT 1 FROM #BackupHeaderLog)
BEGIN
    SELECT TOP 1 @Nm_Arquivo_Log = @Ds_Pasta_Log + subdirectory FROM #BackupHeaderLog ORDER BY ID;

    BEGIN TRY
        INSERT INTO #BackupHeader
        EXEC('RESTORE HEADERONLY FROM DISK = ''' + @Nm_Arquivo_Log + '''');
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao processar arquivo de log: ' + @Nm_Arquivo_Log;
    END CATCH

    DELETE FROM #BackupHeaderLog WHERE ID = (SELECT MIN(ID) FROM #BackupHeaderLog);
END

-- Remove backups inválidos
DELETE FROM #BackupHeader WHERE BackupName IS NULL OR DatabaseName <> @DatabaseOrigem;

-- Obtem nomes lógicos
IF OBJECT_ID('tempdb..#Filelistonly') IS NOT NULL DROP TABLE #Filelistonly;

CREATE TABLE #Filelistonly (
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    [Type] CHAR(1),
    FileGroupName NVARCHAR(128),
    Size NUMERIC(20,0),
    MaxSize NUMERIC(20,0),
    FileID BIGINT,
    CreateLSN NUMERIC(25,0),
    DropLSN NUMERIC(25,0),
    UniqueID UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25,0),
    ReadWriteLSN NUMERIC(25,0),
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupID INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN NUMERIC(25,0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32),
    SnapshotURL NVARCHAR(360)
);

INSERT INTO #Filelistonly
EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @Ds_Caminho_Backup_Full + '''');

DECLARE @logicalnameDATA VARCHAR(MAX),
        @logicalnameLOG VARCHAR(MAX),
        @physicalnameDATA VARCHAR(MAX),
        @physicalnameLOG VARCHAR(MAX);

SELECT @logicalnameDATA = LogicalName, @physicalnameDATA = PhysicalName
FROM #Filelistonly WHERE [Type] = 'D';

SELECT @logicalnameLOG = LogicalName, @physicalnameLOG = PhysicalName
FROM #Filelistonly WHERE [Type] = 'L';

-- Renomeia os arquivos físicos
SELECT
    @physicalnameDATA = REPLACE(@physicalnameDATA, '.mdf', '_' + @DatabaseDestino + '.mdf'),
    @physicalnameLOG = REPLACE(@physicalnameLOG, '.ldf', '_' + @DatabaseDestino + '.ldf');

-- Verifica datas dos backups
DECLARE @Ultimo_Backup_FULL DATETIME, @Ultimo_Backup_Diferencial DATETIME;

SELECT @Ultimo_Backup_FULL = BackupFinishDate FROM #BackupHeader WHERE BackupType = 1;

SELECT @Ultimo_Backup_Diferencial = CASE WHEN BackupFinishDate > @Ultimo_Backup_FULL THEN BackupFinishDate ELSE NULL END
FROM #BackupHeader WHERE BackupType = 5 AND BackupStartDate >= @Ultimo_Backup_FULL;

-- Comando RESTORE FULL
PRINT '-- FULL';
PRINT 'RESTORE DATABASE ' + @DatabaseDestino + ' FROM DISK = ''' + @Ds_Caminho_Backup_Full + ''' WITH NORECOVERY, STATS = 1,';
PRINT 'MOVE ''' + @logicalnameDATA + ''' TO ''' + @physicalnameDATA + ''',';
PRINT 'MOVE ''' + @logicalnameLOG + ''' TO ''' + @physicalnameLOG + '''';

-- RESTORE DIFERENCIAL
IF @Ultimo_Backup_Diferencial IS NOT NULL
BEGIN
    PRINT '';
    PRINT '-- DIFERENCIAL';
    PRINT 'RESTORE DATABASE ' + @DatabaseDestino + ' FROM DISK = ''' + @Ds_Caminho_Backup_Diff + ''' WITH NORECOVERY, STATS = 1';
END

-- Filtra logs válidos
DELETE FROM #BackupHeader WHERE BackupType <> 2;
DELETE FROM #BackupHeader WHERE BackupStartDate < ISNULL(@Ultimo_Backup_Diferencial, @Ultimo_Backup_FULL);

-- Comando RESTORE LOG
PRINT '';
PRINT '-- LOG';

WHILE EXISTS (SELECT 1 FROM #BackupHeader)
BEGIN
    SELECT TOP 1 @ComandoBackupLog = 
        'RESTORE LOG ' + @DatabaseDestino + ' FROM DISK = ''' + @Ds_Pasta_Log + BackupName + @Ds_Extensao_Backup_Log + ''' WITH FILE = 1' +
        CASE WHEN @Ds_Caminho_StandyBy IS NOT NULL THEN ', STANDBY = N''' + @Ds_Caminho_StandyBy + '''' ELSE ', NORECOVERY' END
    FROM #BackupHeader
    ORDER BY BackupStartDate;

    PRINT @ComandoBackupLog;

    DELETE FROM #BackupHeader WHERE BackupName = (SELECT TOP 1 BackupName FROM #BackupHeader ORDER BY BackupStartDate);
END

PRINT '';
PRINT '-- Comando para deixar a base ONLINE';
PRINT 'RESTORE DATABASE ' + @DatabaseDestino + ' WITH RECOVERY';
