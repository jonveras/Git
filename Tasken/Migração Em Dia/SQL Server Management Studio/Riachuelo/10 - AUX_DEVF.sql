
drop table CAD_DEVF_RIACHUELO_CAR10_aux_insert
select contratofixo, num_contrato
into CAD_DEVF_RIACHUELO_CAR10_aux_insert
from CAD_DEVP_RIACHUELO_CAR10 a
INNER JOIN CAD_IDCONTRATO B ON B.CONTRATO_ORIGINAL = A.NUM_CONTRATO collate Latin1_General_CI_AS
LEFT JOIN aux_devf C ON B.CONTRATOFIXO = C.CONTRATO_FIN
where c.CONTRATO_FIN is null
GO

insert into aux_devf (contrato_fin, contrato_original)
select * from CAD_DEVF_RIACHUELO_CAR10_aux_insert
GO

--delete a from aux_devf a join CAD_DEVF_RIACHUELO_CAR10_aux_insert b on a.CONTRATO_FIN = b.CONTRATOFIXO