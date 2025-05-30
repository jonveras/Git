SELECT A.* 
into AUXSRC.dbo.TMK_Carga_Pessoas_4
from
[10.206.4.14].[TMK].[dbo].STDPIC_Carga_Pessoas A
JOIN AUXSRC.[dbo].[TMK_Carga_Dividas_4] B ON A.ContactID = B.ContactID

SELECT A.* 
into AUXSRC.dbo.TMK_Carga_Pagamentos_2
from [10.206.4.14].[TMK].[dbo].STDPIC_Carga_Pagamentos A
JOIN AUXSRC.[dbo].[TMK_PIC_BARUERI_COD_CLI_2] B ON A.DEBTID = B.DebtID

SELECT A.* 
into AUXSRC.dbo.TMK_Carga_Promessas_4
from [10.206.4.14].[TMK].[dbo].STDPIC_Carga_Promessas A
JOIN AUXSRC.[dbo].[TMK_PIC_P_COD_CLI_4] B ON A.DEBTID = B.DebtID

SELECT A.* 
into AUXSRC.dbo.TMK_Carga_PromParc_2
from [10.206.4.14].[TMK].[dbo].STDPIC_Carga_PromParc A
join AUXSRC.dbo.TMK_Carga_Promessas_2 B on A.ArrangementId = B.ArrangementId


--criei para realizar o ultimo insert

DECLARE 
    @DataInicio DATE,
    @DataFim DATE,
    @AnoAtual INT,
    @MesAtual INT,
    @DataCursor DATE,
    @DataIniProc DATETIME,
    @DataFimProc DATETIME,
    @QtdProcessada INT;

-- Detecta menor e maior data na base
SELECT 
    @DataInicio = DATEFROMPARTS(YEAR(MIN(CreationDate)), MONTH(MIN(CreationDate)), 1),
    @DataFim    = DATEFROMPARTS(YEAR(MAX(CreationDate)), MONTH(MAX(CreationDate)), 1)
FROM AUXSRC.dbo.TMK_Carga_Promessas_2;


SELECT MAX(CreationDate) FROM AUXSRC.dbo.TMK_Carga_Promessas_2
-- Inicia no primeiro mês com dados
SET @DataCursor = @DataInicio;

WHILE @DataCursor <= @DataFim
BEGIN
    SET @AnoAtual = YEAR(@DataCursor);
    SET @MesAtual = MONTH(@DataCursor);

    IF NOT EXISTS (
        SELECT 1 
        FROM AUXSRC.DBO.LOG_MIG_TMK
        WHERE ANO = @AnoAtual AND MES = @MesAtual
    )
    BEGIN
        PRINT CONCAT('Processando: ', FORMAT(@DataCursor, 'yyyy-MM'));

        SET @DataIniProc = GETDATE();

        -- Inserção mês a mês
        INSERT INTO AUXSRC.dbo.TMK_Carga_PromParc_2
        SELECT 
			A.*
        FROM 
			[10.206.4.14].[TMK].[dbo].STDPIC_Carga_PromParc AS A
			INNER JOIN AUXSRC.dbo.TMK_Carga_Promessas_2 AS B ON A.ArrangementId = B.ArrangementId
        WHERE 
			B.CreationDate >= @DataCursor
            AND B.CreationDate < DATEADD(MONTH, 1, @DataCursor);

        -- Conta quantos registros foram inseridos neste ciclo
        SET @QtdProcessada = @@ROWCOUNT;

        SET @DataFimProc = GETDATE();

        -- Log
        INSERT INTO AUXSRC.DBO.LOG_MIG_TMK (
            ANO, MES, DATA_INI, DATA_FIN, QTD_REGISTROS
        )
        VALUES (
            @AnoAtual, @MesAtual, @DataIniProc, @DataFimProc, @QtdProcessada
        );
    END

    SET @DataCursor = DATEADD(MONTH, 1, @DataCursor);
END


--spid 232

SELECT * FROM AUXSRC.DBO.LOG_MIG_TMK

SELECT COUNT(1) FROM TMK_Carga_PromParc_2
