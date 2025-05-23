CREATE TABLE dbo.TABELA_LOG (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        DATA_INI DATETIME NOT NULL,
        DATA_FIN DATETIME NOT NULL,
        QTD_REGISTROS INT NOT NULL,
        DATA_LOG DATETIME DEFAULT GETDATE()
    );

DECLARE 
    @DataCursor DATE,
    @DataIniProc DATETIME,
    @DataFimProc DATETIME,
    @QtdProcessada INT,
    @BLOCO INT;


SET @DataCursor = '19990807';
SET @BLOCO = 10000

WHILE 1 = 1
BEGIN
    SET @DataIniProc = GETDATE();

    -- Inserção mês a mês
    DELETE A (@BLOCO)
    FROM
        TABELA AS A
    WHERE
        DATA < @DataCursor

    -- Conta quantos registros foram inseridos neste ciclo
    SET @QtdProcessada = @@ROWCOUNT;

    SET @DataFimProc = GETDATE();

    -- Log
    INSERT INTO TABELA_LOG (
        DATA_INI, DATA_FIN, QTD_REGISTROS
    )
    VALUES (
        @DataIniProc, @DataFimProc, @QtdProcessada
    );

    IF @QtdProcessada = 0
    BREAK;
END
