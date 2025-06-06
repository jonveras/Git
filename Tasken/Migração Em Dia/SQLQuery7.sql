SELECT * 
INTO AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_2
FROM OPENQUERY (CS2,'
SELECT A.NUM_CONTRATO AS ''CONTRATO_ORIGINAL'',B.*
FROM CONTRATO A JOIN PARC_GERAL B ON A.ID_CONTR = B.ID_CONTR
LEFT JOIN ENDERECO C ON A.CPF = C.CPF
LEFT JOIN TELEFONE D ON A.CPF = D.CPF
LEFT JOIN EMAIL E ON A.CPF = E.CPF
WHERE A.ID_CARTEIRA=''11''
AND A.STATUS IN (''8'')
;')


SELECT * 
INTO [CAD_DEVMAIL_SEMPARAR_CAR1]
FROM OPENQUERY (CS2,'
SELECT E.*
FROM CONTRATO A
JOIN EMAIL E ON A.CPF = E.CPF
WHERE A.ID_CARTEIRA=''20''
AND A.STATUS IN (''0'',''4'',''3'',''5'')
;')

SELECT * 
INTO [CAD_DEVE_SEMPARAR_CAR1]
FROM OPENQUERY (CS2,'
SELECT C.*
FROM CONTRATO A
JOIN ENDERECO C ON A.CPF = C.CPF
WHERE A.ID_CARTEIRA=''11''
AND A.STATUS IN (''0'',''4'',''3'',''5'')
;')

SELECT * 
INTO Auxsrc.[dbo].[CADDEVT4_GETNET_2]
FROM OPENQUERY (CS2,'
SELECT C.*
FROM CONTRATO A
JOIN TELEFONE C ON A.CPF = C.CPF
WHERE A.ID_CARTEIRA=''11''
AND A.STATUS IN (''0'',''4'',''3'',''5'')
;')

--drop table Auxsrc.[dbo].[CADDEVE_GETNET_2]

--drop table AUXSRC.dbo.CAD_DEVP_GETNET_AUX_2

SELECT *  
INTO AUXSRC.dbo.CAD_DEVP_GETNET
FROM OPENQUERY (CS2,'        
SELECT A.* FROM PARC_GERAL A
INNER JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
INNER JOIN ACORDO B ON A.ID_ACORDO = B.ID_ACORDO
WHERE C.ID_CARTEIRA = ''350''
AND B.STATUS IN (0, 1, 2, 3)')

SELECT *  
INTO CAD_DEVP4_GETNET_2
FROM OPENQUERY (CS2,'        
SELECT C.NUM_CONTRATO AS ''CONTRATO_ORIGINAL'', A.* FROM PARC_GERAL A
INNER JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
WHERE C.ID_CARTEIRA=''20''
AND C.STATUS IN (''0'',''4'',''3'',''5'')')

SELECT *
INTO CAD_DEVF_SEMPARAR_CAR1
FROM OPENQUERY (CS2,'        
SELECT *
FROM CONTRATO
WHERE ID_CARTEIRA=''20''
AND STATUS IN (''0'',''4'',''3'',''5'') ')

SELECT *
INTO CAD_DEVF_VALIDACAO_GETNET2
FROM OPENQUERY (CS2,'        
SELECT NUM_CONTRATO
FROM CONTRATO
WHERE ID_CARTEIRA=''11''
AND STATUS IN (''0'',''4'',''3'',''5'') ')

SELECT b.* FROM CAD_DEVF_VALIDACAO_GETNET2 A left JOIN CAD_IDCONTRATO B ON A.NUM_CONTRATO COLLATE SQL_Latin1_General_CP1_CI_AS = B.CONTRATO_ORIGINAL
LEFT JOIN CAD_DEVF C ON B.CONTRATOFIXO = C.CONTRATO_FIN
WHERE c.CONTRATO_fin is null or b.CONTRATOFIXO is null

SELECT CONTRATO_fin 
into CAD_DEVF_VALIDACAO2_GETNET2
from cad_devf
where
(
(cad_devf.cod_cli = 142 and cad_devf.cod_car in (1))
)
And
cad_devf.statcont_fin=0

select * from cad_devf where contrato_fin = '33631971ID'

select b.* FROM CAD_DEVF_VALIDACAO_GETNET2 A inner JOIN CAD_IDCONTRATO B ON A.NUM_CONTRATO COLLATE SQL_Latin1_General_CP1_CI_AS = B.CONTRATO_ORIGINAL
left join CAD_DEVF_VALIDACAO2_GETNET2 C ON B.CONTRATOFIXO = C.CONTRATO_FIN
where c.CONTRATO_fin is null

SELECT * FROM CAD_DEVF WHERE CONTRATO_FIN = '42360115ID'

select * from cad_dev where cpf_dev = '39658405000157'

SELECT *  
FROM OPENQUERY (CS2,'        
SELECT * 
FROM CONTRATO
WHERE ID_CARTEIRA=''11''
AND NUM_CONTRATO = ''0009224436'' ')

SELECT *  
FROM OPENQUERY (CS2,'        
SELECT A.* 
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
WHERE C.ID_CARTEIRA=''11''
AND C.NUM_CONTRATO = ''0012993852'' ')

0012993852

SELECT * 
INTO CAD_DEVP2_AJUSTE_GETNET_2
FROM OPENQUERY (CS2,'
SELECT A.NUM_CONTRATO AS ''CONTRATO_ORIGINAL'',B.*
FROM CONTRATO A JOIN PARC_GERAL B ON A.ID_CONTR = B.ID_CONTR
WHERE A.ID_CARTEIRA=''11''
AND A.STATUS IN (''0'',''4'',''3'',''5'')
;')

SELECT *  
INTO ACORDO5_AJUSTE_GETNET2
FROM OPENQUERY (CS2,'        
SELECT C.NUM_CONTRATO AS ''CONTRATO_ORIGINAL'', A.* 
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
WHERE C.ID_CARTEIRA=''11''
AND C.STATUS IN (''0'',''4'',''3'',''5'') ')

--STATUS AS STATUS, NUM_CONTRATO FROM CONTRATO

SELECT * 
	INTO ACORDOS_PARCELAS_ajuste_4_GETNET_2 
FROM OPENQUERY (CS2,'        
SELECT DISTINCT 
	C.NUM_CONTRATO AS CONTRATO_ORIGINAL, 
	C.CPF, 
	A.ID_FUNCIONARIO,
	A.DATA,
	B.*
FROM ACORDO A JOIN PARCELA B ON A.ID_ACORDO = B.ID_ACORDO
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
  AND C.ID_CARTEIRA=''20''
  AND C.STATUS IN (''0'',''4'',''3'',''5'')
;')acordos

--drop table AUXSRC.DBO.ACORDOS_PARCELAS_GETNET_2 

SELECT *  FROM OPENQUERY (CS2,'        
SELECT * FROM PARC_GERAL A
INNER JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
WHERE C.ID_CARTEIRA = ''350''')


SELECT * 
		INTO ACORDOS_4_GETNET_2
FROM OPENQUERY (CS2,'        
SELECT DISTINCT 
	C.NUM_CONTRATO AS CONTRATO_ORIGINAL, 
	A.ID_ACORDO AS ACORDO_ID,
	C.CPF, 
	A.ID_FUNCIONARIO AS FUNCIONARIO_ID,
	A.DATA AS DATA_1,
	A.STATUS AS ''STATUS ACORDO''
	,A.*
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
  AND C.ID_CARTEIRA=''11''
  AND C.STATUS IN (''0'',''4'',''3'',''5'')
;')acordos

DROP TABLE ACORDOS_3_GETNET_2

SELECT * 
		INTO AUXSRC.DBO.ACORDOS_GETNET 
FROM OPENQUERY (CS2,'        
SELECT DISTINCT 
	C.NUM_CONTRATO AS CONTRATO_ORIGINAL, 
	A.ID_ACORDO AS ACORDO_ID,
	C.CPF, 
	A.ID_FUNCIONARIO AS FUNCIONARIO_ID,
	A.DATA AS DATA_1,
	A.STATUS AS ''STATUS ACORDO''
	,A.*
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
  AND C.ID_CARTEIRA=''350''
  AND A.STATUS IN (0, 1, 2, 3)
;')acordos

DROP TABLE AUXSRC.DBO.ACORDOS_GETNET_2 

SELECT * 
		INTO AUXSRC.DBO.ACORDOS5_GETNET_2 
FROM OPENQUERY (CS2,'        
SELECT DISTINCT 
	C.NUM_CONTRATO AS CONTRATO_ORIGINAL, 
	A.ID_ACORDO AS ACORDO_ID,
	C.CPF, 
	A.ID_FUNCIONARIO AS FUNCIONARIO_ID,
	A.DATA AS DATA_1,
	A.STATUS AS ''STATUS ACORDO''
	,A.*
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
  AND C.ID_CARTEIRA=''11''
  AND C.STATUS IN (''0'',''4'',''3'',''5'')
;')acordos

select * from AUXSRC.DBO.ACORDOS_GETNET_2



SELECT * FROM OPENQUERY (CS2,'        
SELECT DISTINCT 
	C.*
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
  AND C.ID_CARTEIRA=''350''
  AND A.STATUS IN (0, 1, 2, 3)
;')acordos


CAD_IDCONTRATO
cad_dev
 
cad_aco

--INSERT INTO CAD_IDCONTRATO(CONTRATO_ORIGINAL, CPF_DEV, DATA_INCLUSAO)
SELECT  
convert(varchar,A.CONTRATO_ORIGINAL),
A.CPF COLLATE SQL_Latin1_General_CP1_CI_AS,
GETDATE()
FROM AUXSRC.DBO.ACORDOS_GETNET A
WHERE NOT EXISTS (SELECT * FROM CAD_IDCONTRATO B WHERE B.CONTRATO_ORIGINAL = convert(varchar,A.CONTRATO_ORIGINAL) AND B.CPF_DEV = A.CPF COLLATE SQL_Latin1_General_CP1_CI_AS)

SELECT * FROM CAD_DEV WHERE CPF_DEV IN (
SELECT CPF_DEV FROM CAD_IDCONTRATO B 
WHERE DATA_INCLUSAO = '2024-07-11 17:46:59.870')

select * from aux_dev WHERE CPF_DEV IN (
SELECT CPF_DEV FROM CAD_IDCONTRATO B 
WHERE DATA_INCLUSAO = '2024-07-11 17:46:59.870')

INSERT INTO AUX_DEV (DATA_INCLUSAO, CPF_DEV) VALUES ('2024-07-11 17:46:59.870','37002415000104')

select top 10 * from cad_devf 
select * from cad_car where desc_car like '%get%'

select top 10 * from cad_idcontrato
where DATA_INCLUSAO IS NOT NULL

select * from cad_idcontrato


SELECT * FROM ACORDO_GETNET
WHERE CONTRATO_ORIGINAL = 'DE0000000088503452' 


USE SRC



SELECT * FROM CAD_DEVF
WHERE
	COD_CLI = 132
	AND COD_CAR =1


	SELECT * FROM CAD_IDCONTRATO
	WHERE CPF_DEV = '51262320291   '


SELECT TOP 10 * FROM BOLETO
WHERE CONTRATO_FIN = ''


SELECT * FROM OPENQUERY (CS2,'        
SELECT 
	*
FROM
	CONTRATO
 WHERE 
	ID_CARTEIRA= ''350''
;')CONTRATO


SELECT * FROM OPENQUERY (CS2,'        
SELECT 
	*
FROM
	CARTEIRA
;')CONTRATO


SELECT * FROM OPENQUERY (CS2,'        
SELECT DISTINCT A.*
FROM ACORDO A 
  JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
  AND C.ID_CARTEIRA=''350''
  AND A.ID_CONTR=''11788795''
;')acordos

A.ID_FUNCIONARIO AS COD_RECUP,
A.DATA AS DATA_ACORDO,

SELECT *  
INTO AUXSRC.dbo.CAD_DEVP_GETNET
FROM OPENQUERY (CS2,'        
SELECT A.* FROM PARC_GERAL A
INNER JOIN CONTRATO C ON C.ID_CONTR = A.ID_CONTR
INNER JOIN ACORDO B ON A.ID_ACORDO = B.ID_ACORDO
WHERE C.ID_CARTEIRA = ''350''
AND B.STATUS IN (0, 1, 2, 3)')


SELECT * FROM OPENQUERY (CS2,'        
SELECT DISTINCT A.*
FROM PARC_FINAN A
;')acordos


cad_devp <> PARC_FINAN








----------------------- ACIONAMENTO


SELECT * 
INTO AUXSRC.DBO.ACIONAMENTOS_GETNET
FROM OPENQUERY (CS2,'        
SELECT B.CPF, A.ID_CONTR, G.NUM_CONTRATO, A.SEQ, A.ID_TEL, A.DATA, A.CODIGO, A.MODO,
       C.ID_FUNCIONARIO, C.LOGIN, C.NOME, C.STATUS, C.CPF_F,
	   D.MOTIVO, D.AUTORIZACAO,
	   E.DDD, E.NUMERO,
	   F.COD, F.HISTORICO
FROM HISTORICO A 
JOIN CONTRATO B ON A.ID_CONTR = B.ID_CONTR 
JOIN PARC_GERAL G ON G.ID_CONTR = A.ID_CONTR
JOIN FUNCIONARIO C ON A.ID_FUNCIONARIO = C.ID_FUNCIONARIO
JOIN HISTORICO_TEXTO D ON A.ID_CONTR = D.ID_CONTR AND A.SEQ = D.SEQ
JOIN TELEFONE E ON B.CPF = E.CPF AND A.ID_TEL = E.ID_TEL
JOIN CODIGO F ON A.CODIGO = F.COD
WHERE B.ID_CARTEIRA=''350'' AND A.DATA >= ''20240101''
;')

SELECT * 
--INTO [dbo].[ACIONAMENTOS_GETNET_AUX_2]
FROM OPENQUERY (CS2,'
SELECT B.CPF, A.ID_CONTR, B.NUM_CONTRATO AS ''CONTRATO_ORIGINAL'', A.SEQ, A.ID_TEL, A.DATA, A.CODIGO, A.MODO,
C.ID_FUNCIONARIO, C.LOGIN, C.NOME, C.STATUS, C.CPF_F,
D.MOTIVO, D.AUTORIZACAO,
E.DDD, E.NUMERO,
F.COD, F.HISTORICO, CONVERT(D.MENSAGEM,CHAR(500)) AS ''COMENTARIO''
FROM HISTORICO A
JOIN CONTRATO B ON A.ID_CONTR = B.ID_CONTR
JOIN PARC_GERAL G ON G.ID_CONTR = A.ID_CONTR
JOIN FUNCIONARIO C ON A.ID_FUNCIONARIO = C.ID_FUNCIONARIO
JOIN HISTORICO_TEXTO D ON A.ID_CONTR = D.ID_CONTR AND A.SEQ = D.SEQ
JOIN TELEFONE E ON B.CPF = E.CPF AND A.ID_TEL = E.ID_TEL
JOIN CODIGO F ON A.CODIGO = F.COD
WHERE B.ID_CARTEIRA=''11''
AND A.DATA >= ''20240101''
AND B.ID_CONTR=''15811115''
ORDER BY A.DATA
;')

SELECT * 
into [ACIONAMENTOS4_GETNET_AUX_2]
FROM OPENQUERY (CS2,'
SELECT B.NUM_CONTRATO, B.CPF, A.ID_CONTR, A.SEQ, A.ID_TEL, A.DATA, A.CODIGO, A.MODO,
C.ID_FUNCIONARIO, C.LOGIN, C.NOME, C.STATUS, C.CPF_F,
D.MOTIVO, D.AUTORIZACAO,
E.DDD, E.NUMERO,
F.COD, F.HISTORICO, CONVERT(D.MENSAGEM,CHAR(500)) AS ''COMENTARIO''
FROM HISTORICO A
LEFT JOIN CONTRATO B ON A.ID_CONTR = B.ID_CONTR
JOIN FUNCIONARIO C ON A.ID_FUNCIONARIO = C.ID_FUNCIONARIO
LEFT JOIN HISTORICO_TEXTO D ON A.ID_CONTR = D.ID_CONTR AND A.SEQ = D.SEQ
LEFT JOIN TELEFONE E ON B.CPF = E.CPF
JOIN CODIGO F ON A.CODIGO = F.COD
WHERE B.ID_CARTEIRA=''11''
AND B.STATUS IN (''0'',''4'',''3'',''5'')
AND A.DATA >= ''20240812''
ORDER BY A.DATA

;')

CAD_DEV, CAD_DEVE, CAD_DEVMAIL, CAD_DEVT
0 - 100%
1 - 50%
2 - 0%

AND B.ID_CONTR=''15811115''

SELECT * FROM [ACIONAMENTOS_GETNET_AUX_2]
where contrato_original = '0011234506'
--AND B.STATUS IN (''0'',''4'',''3'',''5'')

SELECT * FROM [ACIONAMENTOS3_GETNET_AUX_2]
where num_contrato = '0009654763'