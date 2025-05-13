SELECT * 
INTO [CAD_DEVE_CARREFOUR]
FROM OPENQUERY (CS2,'
SELECT C.*
FROM CONTRATO A
JOIN ENDERECO C ON A.CPF = C.CPF
WHERE A.ID_CARTEIRA IN (200,201,202,203,204,205,206,207,208,209,210,211,212,213,214)
AND A.STATUS IN (0,4,3,5)
;')
GO

update [CAD_DEVE_CARREFOUR] set cpf = SUBSTRING(cpf, PATINDEX('%[^0]%', cpf), LEN(cpf))
GO

--WHILE 1 = 1
--BEGIN
--DELETE TOP(100000) A FROM src.dbo.CAD_DEVE A
--JOIN CAD_DEVE_riachuelo_migracao_2_2 B ON A.CPF_DEV = B.CPF collate SQL_Latin1_General_CP1_CI_AS
--IF @@ROWCOUNT < 100000
--	BREAK;
--END
--GO

INSERT INTO src.dbo.CAD_DEVe (CPF_DEV,RUA_END,NUM_END, COMPL_END, BAIRRO_END, CIDADE_END, COD_UF, CEP_END, PERC_end, COD_TIPO, COD_end)
select distinct CPF
,left(RUA,65)
,left(NUMERO,6)
,left(COMPL,30)
,left(BAIRRO,30)
,left(CIDADE,35)
,d.COD_UF
,left(CEP,8),
CASE
	WHEN [STATUS] = 0 THEN 100
	WHEN [STATUS] = 1 THEN 50
	WHEN [STATUS] = 2 THEN 0
END AS SCORE, 
CASE
	WHEN TIPO = 0 THEN 1
	WHEN TIPO = 2 THEN 2
	ELSE 7
END AS TIPO
,(COALESCE(C.COD_end,0) + (row_number() over (partition by cpf order by cpf)) ) as seqnum
--,(row_number() over (partition by cpf order by cpf)) as seqnum
from
[CAD_DEVE_CARREFOUR] a
left join cad_deve  B ON A.CPF collate SQL_Latin1_General_CP1_CI_AS = B.CPF_DEV AND left(CEP,8) COLLATE SQL_Latin1_General_CP1_CI_AS = CEP_END
LEFT join src.dbo.cad_uf d on d.DESC_UF = estado collate SQL_Latin1_General_CP1_CI_AS
OUTER APPLY (SELECT TOP 1 cod_END FROM cad_devE WHERE CPF_DEV = A.CPF collate SQL_Latin1_General_CP1_CI_AS ORDER BY COD_END DESC) C
join src.dbo.cad_dev f ON A.CPF collate SQL_Latin1_General_CP1_CI_AS = f.CPF_DEV
WHERE B.cpf_dev is null
GO

--SELECT * FROM [CAD_DEVE_riachuelo_migracao_2_2]