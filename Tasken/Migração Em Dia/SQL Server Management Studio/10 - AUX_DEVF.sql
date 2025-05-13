
select A.CONTRATO_ORIGINAL AS CONTRATO_FIN, A.CONTRATO_ORIGINAL
into CAD_DEVF_CARREFOUR_aux_insert
from CAD_DEVF_CARREFOUR a
LEFT JOIN aux_devf C ON A.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS = C.CONTRATO_FIN
where c.CONTRATO_FIN is null
GO

insert into aux_devf (contrato_fin, contrato_original)
select DISTINCT * from CAD_DEVF_CARREFOUR_aux_insert
GO

--DELETE FROM AUX_DEVF WHERE CONTRATO_FIN = '44487603ID'
--DELETE FROM AUX_DEVF WHERE CONTRATO_FIN = '44082481ID'

--with cte as (
--select a.contrato_fin, contrato_original,
--row_number() over (partition by contrato_original order by a.contrato_fin) as seqnum
--from aux_devf a
--join cad_devf b on a.contrato_fin = b.contrato_fin
--where b.cod_cli = 136
--)
--select * from cte where seqnum = 2

--delete from aciona where contrato_fin = '44487603ID          '

--with cte as (
--select idcontrato_fin, contrato_original,
--row_number() over (partition by contrato_original order by idcontrato_fin) as seqnum
--from cad_idcontrato )
--select * from cte where seqnum = 2