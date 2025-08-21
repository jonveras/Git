-- Query para ver quem aplicou objetos no banco
select distinct versaoobjeto, name, modify_date, loginname, hostname from AnmVersaoObjetosBD where 
  name like '%PROC_SS_WMS_INVENTARIO_AJUSTE_ESTOQUE%' 
--and LoginName ='TINOCO_SOMA'
order by modify_date desc