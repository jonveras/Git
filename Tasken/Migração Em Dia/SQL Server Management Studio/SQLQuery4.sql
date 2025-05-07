select * from [dbo].[ACORDOS_GETNET_2]

select cpf from [dbo].[CADDEV_2_GETNET_2] a
inner join src.dbo.cad_dev b
on a.cpf = b.cpf_dev collate Latin1_General_CI_AS

SELECT DISTINCT CONTRATO_ORIGINAL, CPF 
into [CADDEV_GETNET_CAD_IDCONTRATO_2]
FROM [CADDEV_GETNET_2]

SELECT DISTINCT CONTRATO_ORIGINAL, PRINCIPAL_ATUAL 
INTO ACORDOS_GETNET_AUX_2
FROM CADDEV_GETNET_2

SELECT * FROM CADDEV_GETNET_2

create clustered index cl_ix on AUXSRC.DBO.[CADDEV_GETNET_CAD_IDCONTRATO_aux_2] (contratofixo)

ALTER TABLE ACORDOS_GETNET_AUX_AUX_2 ADD ID INT IDENTITY (1,1)

create clustered index cl_ix on AUXSRC.DBO.ACORDOS_GETNET_AUX_AUX_2 (ID)

ALTER TABLE CAD_DEVP_GETNET_AUX_2 ADD ID INT IDENTITY (1,1) 

create clustered index cl_ix on AUXSRC.DBO.CAD_DEVP_GETNET_AUX_2 (ID)

with cte
as
(
select
*,
row_number() over (partition by contrato_fin order by venc_parc) as NUm_parc2
from CAD_DEVP4_AJUSTE_GETNET_2_AUX_aux
)
select *
into CAD_DEVP4_AJUSTE_GETNET_2_final
from cte

DROP TABLE CAD_DEVP4_AJUSTE_GETNET_2_final

drop table CAD_DEVP2_AJUSTE_GETNET_2_final

select * from CAD_DEVP_GETNET_AUX_2

select num_parc2, * from CAD_DEVP_GETNET_AUX_aux_2

ALTER TABLE CAD_DEVP_GETNET_AUX_aux_2 ADD ID INT IDENTITY (1,1) 

create clustered index cl_ix on AUXSRC.DBO.CAD_DEVP_GETNET_AUX_aux_2 (ID)