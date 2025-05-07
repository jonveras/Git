3812644673

select * from cad_devf
where cpf_dev = '21394826893'


select * from ACORDO_CARREFOUR
where contrato_original = '66996437464         '

select valor_fin, VALORPRIN_FIN, * from cad_devf
where contrato_fin = '66996437464'

select * from cad_devp
where contrato_fin = '66996437464'

update a set plano_parc = 1 from cad_devp a
join cad_devf b on a.contrato_fin = b.contrato_fin
where cod_cli IN(84,110)
and plano_parc is null

select * from cad_devp a
join cad_devf b on a.contrato_fin = b.contrato_fin
where cod_cli IN(84,110)
and plano_parc is null

select * from CAD_DEVF_CARREFOUR
where cpf = '3812644673'

SELECT *  
--INTO ACORDO_CARREFOUR
FROM OPENQUERY (CS2,'        
SELECT DISTINCT C.NUM_CONTRATO AS ''CONTRATO_ORIGINAL'', A.* 
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
WHERE C.NUM_CONTRATO = ''00003669777''
')
GO

select * from cad_devf where cpf_dev = '1740041410'

select * from cad_devf_carrefour where cpf = '1740041410'

select * from aciona
where CONTRATO_FIN = '67017834184'

SELECT * 
--into ACIONAMENTOS_CARREFOUR
FROM OPENQUERY (CS2,'
SELECT B.NUM_CONTRATO, B.CPF, A.ID_CONTR, A.SEQ, A.ID_TEL, A.DATA, A.CODIGO, A.MODO,
C.ID_FUNCIONARIO, C.LOGIN, C.NOME, C.STATUS, C.CPF_F,
D.MOTIVO, D.AUTORIZACAO,
E.DDD, E.NUMERO,
F.COD, F.HISTORICO, CONVERT(D.MENSAGEM,CHAR(500)) AS ''COMENTARIO''
FROM HISTORICO A
JOIN CONTRATO B ON A.ID_CONTR = B.ID_CONTR
JOIN FUNCIONARIO C ON A.ID_FUNCIONARIO = C.ID_FUNCIONARIO
LEFT JOIN HISTORICO_TEXTO D ON A.ID_CONTR = D.ID_CONTR AND A.SEQ = D.SEQ
LEFT JOIN TELEFONE E ON B.CPF = E.CPF AND A.ID_TEL = E.ID_TEL
JOIN CODIGO F ON A.CODIGO = F.COD
WHERE B.NUM_CONTRATO = ''67017834184''
AND A.DATA >= ''20240923''
ORDER BY A.DATA;')
GO

SELECT * FROM ACIONAMENTOS_CARREFOUR WHERE NUM_CONTRATO = '67017834184'

SELECT COD_STCB, * FROM CAD_DEVF WHERE CPF_DEV = '11092264701'
--67010466620         

SELECT COD_STPA, * FROM CAD_DEVP WHERE CONTRATO_FIN = '67010466620         '

SELECT COD_STCB, a.* FROM CAD_DEVF A
JOIN CAD_DEVF_CARREFOUR B ON A.CONTRATO_FIN = B.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE COD_STCB != 98

WHILE 1 = 1
BEGIN

	UPDATE TOP(100000) A SET COD_STCB = 98 FROM CAD_DEVF A
	JOIN CAD_DEVF_CARREFOUR B ON A.CONTRATO_FIN = B.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE COD_STCB != 98

	IF @@ROWCOUNT < 100000
		BREAK;

END

select nasc_dev, DTNASC_DEV, data_nasc, * from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where nasc_dev not like '%/%'

select top 1 nasc_dev, * from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where nasc_dev <> convert(varchar, convert(date, nasc_dev), 103)

select nasc_dev,  convert(varchar, convert(date,nasc_dev), 103)
from cad_dev where cpf_dev = '6877453735'

while 1 = 1
begin

update top(100000) a set nasc_dev = convert(varchar, convert(date,nasc_dev), 103)
from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where nasc_dev like '%-%'

if @@ROWCOUNT < 100000
	break;

end

while 1 = 1
begin

update top(10000) a set nasc_dev = convert(varchar, dtnasc_dev, 103)
from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where nasc_dev not like '%/%'
and dtnasc_dev is not null

if @@ROWCOUNT < 10000
	break;

end

update top(10000) a set nasc_dev = convert(varchar, data_nasc, 103), DTNASC_DEV = data_nasc
--select nasc_dev, DTNASC_DEV, data_nasc, * 
from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where nasc_dev not like '%/%'

update top(100000) a set DTNASC_DEV = data_nasc
--select DTNASC_DEV, data_nasc, * 
from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where dtnasc_dev is null

update top(100000) a set DTNASC_DEV = data_nasc
--select DTNASC_DEV, data_nasc, * 
from cad_dev a
join cad_devf_carrefour b on a.CPF_DEV = b.cpf COLLATE SQL_Latin1_General_CP1_CI_AS
where dtnasc_dev = '19000101'

SELECT * FROM cad_devf
where cpf_dev = '40201317753'

select * from acordo_carrefour
where CONTRATO_ORIGINAL = '66978300458         '

select * from cad_aco
where contrato_fin = '66978300458         '

select * from ACORDO_PARCELAS_CARREFOUR
where CONTRATO_ORIGINAL = '66978300458         '

select * from ACORDO_PARCELAS_CARREFOUR_INSERT
where CONTRATO_FIN = '66978300458         '

select * from cad_acop 
where contrato_fin = '66978300458         '

UPDATE TOP(100000) C SET VALOR_FIN = A.PRINCIPAL_ATUAL
--SELECT A.PRINCIPAL_ATUAL
FROM CAD_DEVF_CARREFOUR A
--INNER JOIN AUX_DEVF B ON B.CONTRATO_FIN = A.CONTRATO_ORIGINAL collate Latin1_General_CI_AS
JOIN CAD_DEVF C ON A.CONTRATO_ORIGINAL collate Latin1_General_CI_AS = C.CONTRATO_FIN
WHERE A.PRINCIPAL_ATUAL <> C.VALOR_FIN

SELECT A.*
INTO AUX_CYBER_REMESSA_BKP_20241222
from SRC.dbo.[AUX_CYBER_REMESSA] A
JOIN SRC.dbo.CAD_DEVF_CARREFOUR B ON B.CONTRATO_ORIGINAL collate Latin1_General_CI_AS = A.CONTRATO_FIN
JOIN SRC.dbo.CAD_DEVF C ON A.CONTRATO_FIN = C.CONTRATO_FIN
WHERE A.SALDODEVEDOR <> RIGHT('000000000000000'+REPLACE (TRY_CONVERT(VARCHAR,CONVERT(DECIMAL(10,2),VALOR_FIN)), '.', ''),15)
AND C.COD_CLI IN (84,110)

UPDATE A SET SALDODEVEDOR = RIGHT('000000000000000'+REPLACE (TRY_CONVERT(VARCHAR,CONVERT(DECIMAL(10,2),C.VALOR_FIN)), '.', ''),15)
--select TRY_CONVERT(DECIMAL,A.SALDODEVEDOR), SALDODEVEDOR, RIGHT('000000000000000'+REPLACE (TRY_CONVERT(VARCHAR,CONVERT(DECIMAL(10,2),VALOR_FIN)), '.', ''),15), VALOR_FIN
from SRC.dbo.[AUX_CYBER_REMESSA] A
JOIN SRC.dbo.CAD_DEVF_CARREFOUR B ON B.CONTRATO_ORIGINAL collate Latin1_General_CI_AS = A.CONTRATO_FIN
JOIN SRC.dbo.CAD_DEVF C ON A.CONTRATO_FIN = C.CONTRATO_FIN
WHERE A.SALDODEVEDOR <> RIGHT('000000000000000'+REPLACE (TRY_CONVERT(VARCHAR,CONVERT(DECIMAL(10,2),VALOR_FIN)), '.', ''),15)
AND C.COD_CLI IN (84,110)

SELECT *  
INTO ACORDO_CARREFOUR_NUMACORDO
FROM OPENQUERY (CS2,'        
SELECT DISTINCT * 
FROM ACORDO_CARREFOUR B
')
GO

SELECT DISTINCT CONTRATO_ORIGINAL, [DATA], COD_ACORDO_INTERNO
INTO ACORDO_CARREFOUR_NUMACORDO_UPDATE_2
FROM ACORDO_CARREFOUR_NUMACORDO A
JOIN ACORDO_CARREFOUR B ON A.ID_ACORDO = B.ID_ACORDO

CREATE CLUSTERED INDEX CL_IX ON ACORDO_CARREFOUR_NUMACORDO_UPDATE_2 (CONTRATO_ORIGINAL, [DATA])

UPDATE A SET numacordo_aco = COD_ACORDO_INTERNO
--SELECT numacordo_aco
FROM SRC.dbo.CAD_ACO A
JOIN ACORDO_CARREFOUR_NUMACORDO_UPDATE_2 B ON A.CONTRATO_FIN = B.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS AND DTACORDO_ACO = [DATA]

select numacordo_aco, * from cad_aco
where contrato_fin = '10076866697'

select * from cad_devf_carrefour
where CONTRATO_ORIGINAL = '10049492910'

select * from cad_devf
where CONTRATO_fin = '10049492910'

SELECT STATCONT_FIN, a.* FROM CAD_DEVF A (NOLOCK)
JOIN CAD_DEVF_CARREFOUR B ON A.CONTRATO_FIN = B.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE statcont_fin = 1

WHILE 1 =1
BEGIN
UPDATE TOP(10000) A SET STATCONT_FIN = 0 FROM CAD_DEVF A (NOLOCK)
JOIN CAD_DEVF_CARREFOUR B ON A.CONTRATO_FIN = B.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE statcont_fin = 1

IF @@ROWCOUNT < 10000
	BREAK;
END