DECLARE @CAMINHO VARCHAR(4000)

SET @CAMINHO = 'dir \\192.168.9.146\srv-arch03\SRV-SOMADB\RESTORE'

DROP TABLE IF EXISTS #OUTPUT

CREATE TABLE #output (

 SAIDA VARCHAR(4000)

);
 
INSERT INTO #output

EXEC xp_cmdshell @caminho
 
SELECT * FROM #output
 
DELETE FROM #output WHERE SAIDA NOT LIKE '%TRN%' OR saida is null
 
select  'RESTORE LOG [SOMA_TMP] FROM DISK =N''\\192.168.9.146\srv-arch03\SRV-SOMADB\RESTORE\' +  substring(saida, CHARINDEX('s', saida), len(saida)) + ''''+' WITH NORECOVERY' from #output  