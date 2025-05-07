select DISTINCT CPF, DDD, NUMERO, TIPO, SCORE
INTO CAD_DEVT_GETNET_2
from Auxsrc.[dbo].[CADDEVT_GETNET_2]

select * from cad_idcontrato
where CONTRATOFIXO = '42739604ID'

select * from AUXSRC.[dbo].ACORDOS_GETNET_2
where contrato_original = '0004313395'





WITH CTE AS (
SELECT *, 
row_number() over (partition by CPF,cod_tel order by cpf) as seqnum
FROM [CADDEVT_GETNET_AUX_2]
)
SELECT * 
INTO [CADDEVT_GETNET_AUX_aux_2]
FROM CTE 
where seqnum = 1


WITH CTE AS (
SELECT *, 
row_number() over (partition by CONTRATO_ORIGINAL order by VENC_PARC_ABERTO) as NACORDO_ACO
FROM ACORDOS_3_INSERT_GETNET_2
)
SELECT * 
INTO ACORDOS_3_INSERT_AUX_GETNET_2
FROM CTE 


DROP TABLE Auxsrc.[dbo].CAD_DEVT_GETNET_2

CAD_DEVT

ALTER TABLE [CADDEVT_GETNET_AUX_aux_2] ADD ID INT IDENTITY (1,1)

create clustered index cl_ix on [CADDEVT_GETNET_AUX_aux_2] (ID)

DECLARE @VLRINI INT = 1, @VLRFIM INT = 10000

WHILE 1 = 1
BEGIN

	INSERT INTO CAD_DEVT (CPF_DEV, DDD_TEL, TEL_TEL, COD_TIPO, PERC_TEL, COD_TEL)
	SELECT CPF, DDD, NUMERO, TIPO, SCORE, COD_TEL FROM Auxsrc.[dbo].[CADDEVT4_GETNET_2] A
	JOIN CAD_DEV B ON A.CPF = B.CPF_DEV COLLATE Latin1_General_CI_AS
	WHERE ID BETWEEN @VLRINI AND @VLRFIM

	IF @@ROWCOUNT < 1
		BREAK;

	SET @VLRINI = @VLRINI + 10000;
	SET @VLRFIM = @VLRFIM + 10000;
END

select * from 

select a.cpf, a.cod_tel 
--into [CADDEVT_GETNET_AUX_DELETE_2]
from [CADDEVT_GETNET_AUX_2] a
inner join CAD_DEVT b on a.cpf = B.CPF_DEV COLLATE Latin1_General_CI_AS and a.cod_tel = b.cod_tel --a.ddd = b.ddd_tel and a.numero = b.tel_tel collate Latin1_General_CI_AS

--drop table [CADDEVT_GETNET_AUX_DELETE_2]

update a set a.cod_tel = (a.cod_tel + 100) from [CADDEVT_GETNET_AUX_2] a
where cpf = '31444876864'

CPF_DEV CHAR 14
DDD_TEL CHAR 5
TEL_TEL VARCHAR 10
COD_TIPO INT
PERC_TEL INT

SELECT RIGHT(NUMERO,9) FROM [CADDEVT_GETNET_2] WHERE LEN(NUMERO) > 10

UPDATE [CADDEVT_GETNET_2] SET NUMERO = RIGHT(NUMERO,9) WHERE LEN(NUMERO) > 10

SELECT A.* 
INTO [ACORDOS2_GETNET_2]
FROM [dbo].[ACORDOS_GETNET_2] A
INNER JOIN SRC.DBO.CAD_IDCONTRATO B ON A.CONTRATO_ORIGINAL = B.CONTRATO_ORIGINAL COLLATE Latin1_General_CI_AS
WHERE B.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

select * FROM AUXSRC.DBO.[ACORDOS2_GETNET_2] where VENC_PARC_ABERTO is null

SELECT * FROM CAD_ACO WHERE CONTRATO_FIN = '42687250ID'

DROP TABLE [ACORDOS2_GETNET_2]

INSERT INTO CAD_ACO (CONTRATO_FIN, NACORDO_ACO, PARCELA_ACO, DTACORDO_ACO, PLANO_ACO, VLRACORDO_ACO, VENC_ACO, COD_STAC)
SELECT
CONTRATOFIXO,
1 AS NACORDO_ACO,
NUM_PARC_PRIM AS PARCELA_ACO,
DATA AS DTACORDO_ACO,
NUM_PARCELAS AS PLANO_ACO,
PRINCIPAL AS VLRACORDO_ACO,
VENC_PARC_ABERTO AS VENC_ACO,
STATUS
FROM ACORDO5_AJUSTE_GETNET2 A
INNER JOIN CAD_IDCONTRATO B ON B.CONTRATO_ORIGINAL = CONVERT(varchar,A.CONTRATO_ORIGINAL) COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE A.STATUS <> 7 AND B.DATA_INCLUSAO = '20240813'

SELECT B.CONTRATO_FIN FROM CAD_IDCONTRATO A JOIN CAD_ACO B ON A.CONTRATOFIXO = B.CONTRATO_FIN
WHERE A.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

with cte
as (
SELECT
B.CONTRATO_FIN,
NACORDO_ACO,
NUM_PARC AS PARCELA_ACOP,
'A' AS TIPO_PARCACO,
B.PLANO_ACO AS PLANO_ACOP,
PRINCIPAL_O AS VALOR_ACOP,
VENCIMENTO AS VENC_ACOP,
STATUS AS COD_STPA,
JUROS_O AS VLRJUR_ACOP,
MULTA_O AS VLRMUL_ACOP,
row_number() over (partition by B.CONTRATO_FIN, B.NACORDO_ACO, NUM_PARC order by NACORDO_ACO) as SEQNUM
FROM ACORDOS_PARCELAS_ajuste_4_GETNET_2  A
INNER JOIN CAD_IDCONTRATO C ON C.CONTRATO_ORIGINAL = CONVERT(varchar,A.CONTRATO_ORIGINAL) collate SQL_Latin1_General_CP1_CI_AS
INNER JOIN CAD_ACO AS B ON C.CONTRATOFIXO = B.CONTRATO_FIN
WHERE C.DATA_INCLUSAO = '20240813'
)
select * 
into ACORDOS_PARCELAS_4_AUX_INSERT_GETNET_2
from cte
where seqnum = 1

INSERT INTO CAD_ACOP (CONTRATO_FIN, NACORDO_ACO, PARCELA_ACOP, TIPO_PARCACO, PLANO_ACOP, VALOR_ACOP, VENC_ACOP, COD_STPA, VLRJUR_ACOP, VLRMUL_ACOP)
SELECT
A.CONTRATO_FIN,
A.NACORDO_ACO,
A.PARCELA_ACOP,
A.TIPO_PARCACO,
A.PLANO_ACOP,
A.VALOR_ACOP,
A.VENC_ACOP,
A.COD_STPA,
A.VLRJUR_ACOP,
A.VLRMUL_ACOP
FROM ACORDOS_PARCELAS_4_AUX_INSERT_GETNET_2 A

DELETE FROM AUXSRC.DBO.ACORDOS_PARCELAS_aux_GETNET_2 WHERE CONTRATO_FIN = '42650123ID          '

insert into CAD_DEVMAIL
select cpf collate SQL_Latin1_General_CP1_CI_AS as cpf_dev
, email collate SQL_Latin1_General_CP1_CI_AS as desc_devmail, score as perc_Mail, observacao as obs_mail 
--into #delete_aux_ddg_2
from Auxsrc.[dbo].[CADDEVE_GETNET_2] a
join cad_devmail b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev and a.email collate SQL_Latin1_General_CP1_CI_AS = b.desc_devmail

delete a from Auxsrc.[dbo].[CADDEVE_GETNET_2] a
join #delete_aux_ddg b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev and a.email collate SQL_Latin1_General_CP1_CI_AS = b.desc_devmail

WITH CTE AS (
select cpf collate SQL_Latin1_General_CP1_CI_AS as cpf_dev
, email collate SQL_Latin1_General_CP1_CI_AS as desc_devmail, score as perc_Mail, observacao as obs_mail,
row_number() over (partition by cpf order by score) as cod_devmail
from Auxsrc.[dbo].[CADDEVE_GETNET_2] a
join cad_dev b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev
)
SELECT * 
INTO [CADDEVE_AUX_GETNET_2]
FROM CTE 
 
SELECT DISTINCT A.CPF_DEV, A.cod_devmail
INTO #DDG_7
FROM [CADDEVE_AUX_GETNET_2] A
JOIN CAD_DEVMAIL B ON A.CPF_DEV = B.CPF_DEV AND A.cod_devmail = B.COD_DEVMAIL

UPDATE A SET A.COD_DEVMAIL = (A.COD_DEVMAIL + 50) FROM [CADDEVE_AUX_GETNET_2] A
JOIN #DDG_6 B ON A.CPF_DEV = B.CPF_DEV AND A.cod_devmail = B.cod_devmail


select distinct cpf_dev, desc_devmail, perc_mail, obs_mail
into [CADDEVE_AUX_aux_GETNET_2]
from [CADDEVE_AUX_GETNET_2] a

with cte as (
select *,
row_number() over (partition by cpf_dev order by perc_mail) as cod_devmail
from [CADDEVE_AUX_aux_GETNET_2] a
)
SELECT * 
INTO [CADDEVE_AUX2_GETNET_2]
FROM CTE 

select a.cpf_dev, max(a.cod_devmail)  as cod_devmail
into #ddg_1
from cad_devmail a
join (
select a.cpf_dev from [CADDEVE_AUX2_GETNET_2] a
join cad_devmail b on a.cpf_dev = b.cpf_dev and a.cod_devmail = b.cod_devmail) b
on a.cpf_dev = b.cpf_dev
group by a.cpf_dev

UPDATE A SET A.COD_DEVMAIL = (b.COD_DEVMAIL + 2) 

--select a.cpf_dev, a.cod_devmail, b.cod_devmail
FROM [CADDEVE_AUX2_GETNET_2] A
join cad_devmail c on a.cpf_dev = c.cpf_dev and c.cod_devmail = a.cod_devmail 
JOIN #DDG_1 B ON c.CPF_DEV = B.CPF_DEV --AND c.cod_devmail = B.cod_devmail

insert into CAD_DEVMAIL (CPF_DEV, DESC_DEVMAIL, PERC_MAIL, OBS_MAIL, COD_DEVMAIL)
select CPF_DEV, DESC_DEVMAIL, PERC_MAIL, OBS_MAIL, COD_DEVMAIL from [CADDEVE_AUX3_GETNET_2]

select * from [CADDEVE_AUX3_GETNET_2] where cpf_dev = '10531705722'
select * from [CAD_devmail] where cpf_dev = '10013728000101'
select * from #ddg_1 where cpf_dev = '10013728000101'

select a.* from [CADDEVE_AUX3_GETNET_2] a
join cad_devmail b on a.cpf_dev = b.cpf_dev and a.cod_devmail = b.cod_devmail

delete top(1) from [CADDEVE_AUX2_GETNET_2] where cpf_dev = '10049308602'

with cte as (
select * 
,row_number() over (partition by cpf_dev, cod_devmail order by perc_mail) as seqnum
from [CADDEVE_AUX3_GETNET_2]
)
select * from cte
--update 
----into aux_ddg
--cte
--set cod_devmail = 20
where seqnum > 1

select cpf_dev, desc_devmail, perc_mail, obs_mail, (cod_devmail + seqnum) as cod_devmail
into [CADDEVE_AUX3_GETNET_2]
from aux_ddg

SELECT * FROM AUXSRC.DBO.[CADDEVEND_GETNET_2]

select distinct
cpf collate SQL_Latin1_General_CP1_CI_AS as cpf_dev,
rua collate SQL_Latin1_General_CP1_CI_AS as rua_end, 
bairro collate SQL_Latin1_General_CP1_CI_AS as bairro_end, 
cidade collate SQL_Latin1_General_CP1_CI_AS as cidade_end, 
b.cod_uf, 
cep collate SQL_Latin1_General_CP1_CI_AS as cep_end, 
score as perc_end, 
numero  collate SQL_Latin1_General_CP1_CI_AS as num_end, 
compl collate SQL_Latin1_General_CP1_CI_AS as compl_end, 
observacao as obs_end  
into CAD_DEVE_GENET_2
from Auxsrc.[dbo].[CADDEVEND_GETNET_2] a
join cad_uf b on a.ESTADO collate SQL_Latin1_General_CP1_CI_AS= b.DESC_UF
JOIN cad_dev c on a.cpf  collate SQL_Latin1_General_CP1_CI_AS = c.cpf_dev

with cte as (
select a.cpf
,a.rua
,a.bairro
,a.cidade
,a.ESTADO
,a.cep
,a.SCORE
,a.numERO
,a.compl
,a.obsERVACAO, c.COD_UF, COALESCE((max(b.cod_end)+1), 0) as vlr_ini
,row_number() over (partition by a.cpf order by a.score) as seqnum
from AUXSRC.DBO.[CADDEVEND3_GETNET_2] a
INNER JOIN CAD_UF c ON A.ESTADO collate SQL_Latin1_General_CP1_CI_AS = c.DESC_UF
left join cad_deve b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.CPF_DEV
group by
a.cpf
,a.rua
,a.bairro
,a.cidade
,a.ESTADO
,a.cep
,a.SCORE
,a.numERO
,a.compl
,a.obsERVACAO
,c.cod_uf
)
select
 a.cpf
,a.rua
,a.bairro
,a.cidade
,a.cod_uf
,a.cep
,a.score
,a.numero
,a.compl
,a.obsERVACAO
,(a.vlr_ini + a.seqnum) as cod_end
into CAD_DEVE3_AUX_GENET_2
from cte a

drop table CAD_DEVE3_AUX_GENET_2

INSERT INTO cad_deve (cpf_dev, cod_end, rua_end, bairro_end, cidade_end, cod_uf, cep_end, perc_end, num_end, compl_end, obs_end, COD_TIPO)
SELECT cpf collate SQL_Latin1_General_CP1_CI_AS, cod_end, substring(rua, 1, 65), substring(bairro,1,30), substring(cidade,1,35), a.cod_uf, substring(cep, 1, 8), score, substring(numero, 1, 6), substring(compl,1,30), observacao, 0
FROM CAD_DEVE3_AUX_GENET_2 a inner join cad_dev b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev

--delete a from CAD_DEVE3_AUX_GENET_2 a inner join cad_dev b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev where b.cpf_dev is null

--rua 65
--cep 8
--numero 6

with cte as (
select CPF, DDD, NUMERO, TIPO, SCORE, COALESCE((max(b.cod_tel)+1), 0) as vlr_ini
,row_number() over (partition by a.cpf order by a.score) as seqnum
from AUXSRC.DBO.[CADDEVT3_GETNET_2] a
outer apply (select top 1 cod_tel from cad_devt b where a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.CPF_DEV) b
group by
CPF, DDD, NUMERO, TIPO, SCORE, COD_TEL
)
select
 CPF, DDD, NUMERO, TIPO, SCORE
,(a.vlr_ini + a.seqnum) as cod_tel
into CAD_DEVt3_AUX_GENET_2
from cte a

INSERT INTO cad_devt (CPF_DEV, DDD_TEL, TEL_TEL, COD_TIPO, PERC_TEL, COD_TEL)
	SELECT DISTINCT CPF, DDD, NUMERO, TIPO, COALESCE(SCORE,0), (COD_TEL+5000)
FROM CAD_DEVt3_AUX_GENET_2 a inner join cad_dev b on a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev

with cte as (
select cpf collate SQL_Latin1_General_CP1_CI_AS as cpf_dev
, email collate SQL_Latin1_General_CP1_CI_AS as desc_devmail, score as perc_Mail, observacao as obs_mail, COALESCE((max(b.cod_devmail)+1), 0) as vlr_ini
,row_number() over (partition by a.cpf order by a.score) as seqnum
from AUXSRC.DBO.[CADDEVE3_GETNET_2] a
outer apply (select top 1 cod_devmail from cad_devmail b where a.cpf collate SQL_Latin1_General_CP1_CI_AS = b.CPF_DEV) b
group by
CPF, email, score, observacao
)
select
 cpf_dev, desc_devmail, perc_mail, obs_mail
,(a.vlr_ini + a.seqnum) as cod_tel
into CAD_DEVmail3_AUX_GENET_2
from cte a

INSERT INTO cad_devmail (cpf_dev, desc_devmail, perc_mail, obs_mail, cod_devmail)
	SELECT DISTINCT a.cpf_dev, desc_devmail, coalesce(perc_mail,0), obs_mail, (cod_tel+80)
FROM CAD_DEVmail3_AUX_GENET_2 a inner join cad_dev b on a.cpf_dev collate SQL_Latin1_General_CP1_CI_AS = b.cpf_dev

delete from CAD_DEVmail3_AUX_GENET_2 where cpf_dev = '9353092841 '

select  CPF, DDD, NUMERO, TIPO, SCORE, COD_TEL from CAD_DEVt3_AUX_GENET_2 where cpf = '1000206157'

select cep from CAD_DEVE3_AUX_GENET_2 where len(cep) > 8

select * from cad_uf