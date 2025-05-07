
INSERT INTO CAD_IDCONTRATO(CONTRATO_ORIGINAL, CPF_DEV, DATA_INCLUSAO)
SELECT  
b.contratofixo as contrato_fin, a.*
into CAD_DEVF5_novos_GETNET2
from CAD_DEVF5_GETNET2 a inner join CAD_IDCONTRATO b on a.num_contrato collate SQL_Latin1_General_CP1_CI_AS = b.contrato_Original
where b.DATA_INCLUSAO = '20240813'

select * from CAD_DEVF5_novos_GETNET2

SELECT  
cod_stcb, b.*
--into CAD_DEVF5_novos_GETNET2
--update c set COD_STCB = 98
--into cad_devf_codstcb_genet2_2040814
from cad_devf c join CAD_IDCONTRATO b on b.CONTRATOFIXO = c.contrato_fin
--left join CAD_DEVF5_GETNET2 a on a.num_contrato collate SQL_Latin1_General_CP1_CI_AS = b.contrato_Original 
where --a.id_contr is null and 
(b.DATA_INCLUSAO = '20240811' or b.DATA_INCLUSAO = '2024-08-04 21:34:37.247' or b.DATA_INCLUSAO = '20240813')
--and statcont_fin = 1 
and COD_STCB != 98