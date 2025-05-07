select STATUS, COD_STPA, a.* from cad_devp a
join AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 b on a.CONTRATO_FIN = b.CONTRATO_FIN
--where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
--and COD_STPA IS NULL

select distinct a.* from [ACIONAMENTOS_GETNET_AUX_2] a
join CAD_IDCONTRATO b on a.CONTRATO_ORIGINAL collate SQL_Latin1_General_CP1_CI_AS = b.CONTRATO_ORIGINAL
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

select statcont_fin, * from cad_devf
join CAD_IDCONTRATO b on a.CONTRATO_FIN = b.CONTRATOfixo
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

select contrato_fin, data_aciona, cod_recup, ddd_tel, tel_tel, cod_acionamento from ACIONA a
join CAD_IDCONTRATO b on a.CONTRATO_FIN = b.CONTRATOfixo
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

with cte as (
select ID, 
row_number() over (partition by contrato_fin, data_aciona, cod_recup, ddd_tel, tel_tel, cod_acionamento order by id) as seqnum
from ACIONA a
join CAD_IDCONTRATO b on a.CONTRATO_FIN = b.CONTRATOfixo
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
)
select id 
into delete_aciona
from cte where seqnum > 1


delete from aciona where id in (select * from delete_aciona)


select * from AUXSRC.DBO.ACORDOS_GETNET_2 

UPDATE A SET COD_STPA = STATUS from cad_devp a
join AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 b on a.CONTRATO_FIN = b.CONTRATO_FIN

select a.* from cad_aco a where contrato_fin = '42757874ID'

SELECT * FROM CAD_IDCONTRATO WHERE CONTRATOFIXO = '42757874ID'

select status_aco, a.* from cad_aco a join CAD_IDCONTRATO b on a.CONTRATO_FIN = b.CONTRATOFIXO
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

select status,  from AUXSRC.DBO.ACORDOS3_GETNET_2 a join CAD_IDCONTRATO b on a.CONTRATO_original collate SQL_Latin1_General_CP1_CI_AS = b.contrato_original
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

select a.* from cad_acop a where contrato_fin = '42964113ID'

select * from cad_idcontrato where contrato_original = '0000070843'

select * from cad_idcontrato where contratofixo = '42856175ID'
--15812704
--0010617080 

select * from AUXSRC.dbo.CAD_DEVP_GETNET_AUX_2
where contrato_original = '0010617080'

select B.CONTRATOFIXO AS CONTRATO_FIN, STATUS, VENC
INTO AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2
from AUXSRC.dbo.CAD_DEVP_GETNET_AUX_2 A 
INNER JOIN CAD_IDCONTRATO B ON A.CONTRATO_ORIGINAL collate SQL_Latin1_General_CP1_CI_AS = B.CONTRATO_ORIGINAL


UPDATE AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 SET STATUS = 3  WHERE STATUS =   0
UPDATE AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 SET STATUS = 0  WHERE STATUS = 	1
UPDATE AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 SET STATUS = 6  WHERE STATUS = 	2
UPDATE AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 SET STATUS = 0  WHERE STATUS = 	3
UPDATE AUXSRC.DBO.CAD_DEVP_GETNET_AUX_AJUSTE_2 SET STATUS = 15 WHERE STATUS = 	5

select a.* 
into AUXSRC.dbo.CAD_DEVP2_GETNET_AUX__filtrado_2
from AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_2 a
join cad_Idcontrato b on a.contrato_original collate SQL_Latin1_General_CP1_CI_AS = b.contrato_original
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

select a.* 
--delete a
from AUXSRC.dbo.CAD_DEVP2_GETNET_AUX__filtrado_2 a
join cad_Idcontrato b on a.contrato_original collate SQL_Latin1_General_CP1_CI_AS = b.contrato_original
join cad_devp c on b.CONTRATOFIXO = c.CONTRATO_FIN
where b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'

with cte as (
select b.contratofixo as contrato_fin,
a.*,
row_number() over (partition by a.contrato_original order by a.VENC) as seqnum
from AUXSRC.dbo.CAD_DEVP2_GETNET_AUX__filtrado_2 a
join cad_Idcontrato b on a.contrato_original collate SQL_Latin1_General_CP1_CI_AS = b.contrato_original
)
select * into AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_insercao_2
from cte

select * FROM AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_insercao_2
where status <> 6

UPDATE AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_insercao_2 SET STATUS = 6 where status = 2
/*
0 = ACORDO  -  3 
1 = ATRASO - 0
2 = DEVOLVIDO - 6
3 = EM ABERTO - 0
4 = PAG. DEIRETO - 4
5 = LIQUIDADO - 15 
*/

INSERT INTO CAD_DEVP (CONTRATO_FIN, PARCELA_PARC, TIPO_PARC, VENC_PARC, VALOR_PARC, COD_STPA)
	SELECT
	CONTRATO_FIN,
	A.seqnum AS PARCELA_PARC,
	'P' AS TIPO_PARC,
	A.VENC AS VENC_PARC,
	A.VALOR AS VALOR_PARC,
	STATUS AS COD_STPA
	FROM AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_insercao_2 A
	--WHERE B.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
	--WHERE ID BETWEEN @VLRINI AND @VLRFIM

select a.* from AUXSRC.dbo.CAD_DEVP2_GETNET_AUX_insercao_2 a left join cad_devf b on a.contrato_fin = b.contrato_fin where b.contrato_fin is null

SELECT * FROM AUXSRC.dbo.CAD_DEVP_GETNET_AUX_2 WHERE CONTRATO_ORIGINAL = '15812704'


select a.* 
--into cad_acop_getnet_status_null
--delete a
from cad_acop a inner join cad_idcontrato b on a.CONTRATO_FIN = b.CONTRATOFIXO
left join AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 c on a.CONTRATO_FIN = c.contratofixo
where  b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
and c.contratofixo is null

select a.* 
--into cad_aco_getnet_status_null
--delete a
from cad_aco a inner join cad_idcontrato b on a.CONTRATO_FIN = b.CONTRATOFIXO
--left join AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 c on a.CONTRATO_FIN = c.contratofixo
where  b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
and c.contratofixo is null

select * from cad_acop

select status, contratofixo 
into AUXSRC.DBO.ACORDOS_ajuste_GETNET_2
from AUXSRC.DBO.ACORDOS_GETNET_2 a
join cad_idcontrato b on a.CONTRATO_ORIGINAL collate SQL_Latin1_General_CP1_CI_AS = b.CONTRATO_ORIGINAL
where  b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
and status <> 7

drop table AUXSRC.DBO.ACORDOS_ajuste_GETNET_2

select * from cad_idcontrato where contratofixo = '42660620ID          '

select * from AUXSRC.dbo.ACORDOS3_GETNET_2 where contrato_original = '15808698'

update a set cod_stac = status from cad_aco a join AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 b on a.CONTRATO_FIN = b.CONTRATOFIXO

select * from cad_acop where CONTRATO_FIN = '42757874ID'

select * from AUXSRC.DBO.ACORDOS_GETNET_2

alter table AUXSRC.DBO.ACORDOS_GETNET_2
alter column status int


UPDATE AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 SET STATUS = 0 WHERE STATUS =  14 
UPDATE AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 SET STATUS = 3 WHERE STATUS =  5  
UPDATE AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 SET STATUS = 0 WHERE STATUS =  83 
UPDATE AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 SET STATUS = 1 WHERE STATUS =  13 
UPDATE AUXSRC.DBO.ACORDOS_ajuste_GETNET_2 SET STATUS = 2 WHERE STATUS =  485

0 = COBRANCA 14
3 = PROPOSTA DE ACORDO - 5
4 = ACORDO - 83
5 = ACORDO EM ATRASO - 13
8 = DEVOLVIDO - 485

select a.* from cad_aco a
join cad_idcontrato b on a.CONTRATO_FIN = b.CONTRATOFIXO
where  b.DATA_INCLUSAO = '2024-08-04 21:34:37.247'
b.CONTRATO_ORIGINAL = '0000162308'

select * from AUXSRC.DBO.ACORDOS_PARCELAS_GETNET_2
where CONTRATO_ORIGINAL = '0000162308'

SELECT * FROM CAD_DEVP WHERE CONTRATO_FIN = '42660629ID'

SELECT
--B.CONTRATO_FIN,
--NACORDO_ACO,
NUM_PARC AS PARCELA_ACOP,
'A' AS TIPO_PARCACO,
--B.PLANO_ACO AS PLANO_ACOP,
PRINCIPAL_O AS VALOR_ACOP,
VENCIMENTO AS VENC_ACOP,
3 AS COD_STPA,
JUROS_O AS VLRJUR_ACOP,
MULTA_O AS VLRMUL_ACOP
,C.CONTRATOFIXO
--,row_number() over (partition by B.CONTRATO_FIN, B.NACORDO_ACO, NUM_PARC order by NACORDO_ACO) as SEQNUM
FROM AUXSRC.DBO.ACORDOS_PARCELAS_GETNET_2  A
INNER JOIN CAD_IDCONTRATO C ON C.CONTRATO_ORIGINAL = CONVERT(varchar,A.CONTRATO_ORIGINAL) collate SQL_Latin1_General_CP1_CI_AS
--INNER JOIN CAD_ACO AS B ON C.CONTRATOFIXO = B.CONTRATO_FIN
where c.CONTRATO_ORIGINAL = '0000162308'

select * from cad_idcontrato where contrato_original = '0000162308'

select * from ACORDOS_GETNET_2

select * from cad_dev where cpf_dev = '05558092000143'

SELECT COBRANCA_FIN, STATCONT_FIN,* FROM CAD_DEVF WHERE CPF_DEV = '1361041587'


SELECT 
                                Nome          = A.NOME_DEV,
                                NomeSocial    = A.NOME_SOCIAL,
                                Mae           = A.MAE_DEV,
                                Empresa       = RTRIM(A.EMPRESA_DEV),
                                CpfCnpj       = RTRIM(A.CPF_DEV),
                                RG            = A.RG_DEV,
                                DataExpedicao = A.EXP_DEV,
                                Pai           = A.PAI_DEV,
                                Profissao     = RTRIM(A.PROFISSAO_DEV),
                                Nascimento    = A.DTNASC_DEV,
                                Orgao         = A.ORG_DEV,
                                EstadoCivil   = RTRIM(B.DESC_ESTCIV),
                                Sexo          = RTRIM(C.DESC_SEXO),
                                ConjugeCPF    = RTRIM(A.CONJCPF_DEV),
                                ConjugeNome   = A.CONJNOME_DEV,
                                SenhaDEBT     = A.VIRCOBWEBSENHA_DEV,
                                DDD           = RTRIM(D.DDD_TEL),
                                Telefone      = D.TEL_TEL,
                                Email         = RTRIM(E.DESC_DEVMAIL),
                                DataNascimento= RTRIM(A.NASC_DEV)
                                FROM 
                                CAD_DEV(NOLOCK) AS A
                                LEFT JOIN 
                                    CAD_ESTCIV(NOLOCK) AS B ON A.COD_ESTCIV = B.COD_ESTCIV
                                LEFT JOIN 
                                    CAD_SEXO(NOLOCK) AS C ON A.COD_SEXO = C.COD_SEXO
                                LEFT JOIN 
                                    CAD_DEVT(NOLOCK) AS D ON D.CPF_DEV = A.CPF_DEV
                                LEFT JOIN 
                                    CAD_DEVMAIL(NOLOCK) AS E ON A.CPF_DEV = E.CPF_DEV AND (E.COD_REF IS NULL OR E.COD_REF = 0)
                                WHERE 
                                    A.CPF_DEV = '22434264808' ORDER BY E.DESC_DEVMAIL DESC, D.PERC_TEL DESC

SELECT TOP 100
        A.DESC_CAR, A.CONTROLE_CAR, CONTROLE_CAR, B.CONTRATO_FIN, A.COD_CLI, A.COD_CAR, B.CPF_DEV, b.COBRANCA_FIN, b.STATCONT_FIN
    FROM 
        CAD_CAR(NOLOCK) AS A 
    JOIN 
        CAD_DEVF(NOLOCK) AS B ON A.COD_CLI = B.COD_CLI AND A.COD_CAR = B.COD_CAR 
    WHERE 
        A.COD_CLI = 136 AND B.STATCONT_FIN = 0 AND B.COBRANCA_FIN = 0

SELECT 
                                    Senha   = LTRIM(RTRIM(A.SENHASYSOPEN_CAR)),
                                    Usuario = LTRIM(RTRIM(A.USUARIOSYSOPEN_CAR)),
                                    Empresa = LTRIM(RTRIM(A.EMPRESASYSOPEN_CAR)),
                                    Url     = LTRIM(RTRIM(A.URLSYSOPEN_CAR))
                                 FROM 
                                    CAD_CAR(NOLOCK) AS A 
                                 JOIN 
                                    CAD_DEVF(NOLOCK) AS B ON A.COD_CLI = B.COD_CLI AND A.COD_CAR = B.COD_CAR 
                                 WHERE 
                                    B.CONTRATO_FIN = '34964545ID'

SELECT * FROM configura_VERTICAL WHERE CAMPO = 'URL_SYSOPEN_CONF'
SELECT  * FROM CAD_RECUP WHERE LOGIN_RECUP IN ('SRC_DESKTOP', 'PORTAL_AUTO_NEGOCIACAO', 'master')





