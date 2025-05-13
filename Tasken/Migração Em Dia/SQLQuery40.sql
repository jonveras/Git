INSERT INTO acordo_carrefour_aux
select distinct contrato_fin 
FROM CAD_ACO A
	JOIN ACORDO_CARREFOUR B ON TRY_CONVERT(INT,A.ID_EXTERNO) = B.ID_ACORDO
	WHERE NUMACOCON_ACO IS NULL
--287780

SELECT * FROM acordo_carrefour_aux

--TRUNCATE TABLE acordo_carrefour_aux

sp_spaceused acordo_carrefour_aux

select count(a.contrato_fin) FROM CAD_ACO A
join acordo_carrefour_aux b on a.CONTRATO_FIN = b.contrato_fin
WHERE NUMACOCON_ACO IS NULL
--140899
--136979
--136425
--133892
--70463
--63425

select count(a.contrato_fin) 
--DELETE B 
FROM CAD_ACO A
join acordo_carrefour_aux b on a.CONTRATO_FIN = b.contrato_fin
WHERE NUMACOCON_ACO IS NOT NULL

SELECT DISTINCT(CONTRATO_FIN) FROM CAD_ACO A
JOIN ACORDO_CARREFOUR B ON TRY_CONVERT(INT,A.ID_EXTERNO) = B.ID_ACORDO
	WHERE NUMACOCON_ACO IS NULL

	with cte as (
select a.contrato_fin, nacordo_aco, NUMACOCON_ACO, cod_cli
,row_number() over (partition by numacocon_aco order by dtacordo_aco desc) as seqnum
from cad_aco a
join cad_devf b on a.contrato_fin = b.contrato_fin
where numacocon_aco is not null and NUMACOCON_ACO > 50000000
)
select * 
into cad_aco_duplicadas_20241121
from cte where seqnum > 1
and cod_cli in (84,110)

select numacocon_aco, * from cad_aco
where contrato_fin in (
--'40864083ID'
'49605586id'
)

58502570
58941056
59427848

59390651
59392727

select a.NUMACOCON_ACO, a.* 
--into cad_aco_bkp_numacocon_aco_20241121_delete
from cad_aco a
join cad_devf b on a.contrato_fin = b.contrato_fin
join cad_aco_duplicadas_20241121 c on a.contrato_fin = c.contrato_fin and a.NUMACOCON_ACO = c.NUMACOCON_ACO

begin tran
update a set NUMACOCON_ACO = null
from cad_aco a
join cad_devf b on a.contrato_fin = b.contrato_fin
join acordo_carrefour c on a.contrato_fin = c.CONTRATO_ORIGINAL COLLATE SQL_Latin1_General_CP1_CI_AS and DTACORDO_ACO = [DATA]
where cod_cli in (110, 84)
commit

select * from cad_aco_duplicadas_20241121