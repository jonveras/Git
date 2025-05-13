SELECT A.* 
into AUXSRC.dbo.TMK_Carga_Pessoas_4
from
[10.206.4.14].[TMK].[dbo].STDPIC_Carga_Pessoas A
JOIN AUXSRC.[dbo].[TMK_Carga_Dividas_4] B ON A.ContactID = B.ContactID

SELECT A.* 
into AUXSRC.dbo.TMK_Carga_Pagamentos_2
from [10.206.4.14].[TMK].[dbo].STDPIC_Carga_Pagamentos A
JOIN AUXSRC.[dbo].[TMK_PIC_BARUERI_COD_CLI_2] B ON A.DEBTID = B.DebtID

SELECT A.* 
into AUXSRC.dbo.TMK_Carga_Promessas_4
from [10.206.4.14].[TMK].[dbo].STDPIC_Carga_Promessas A
JOIN AUXSRC.[dbo].[TMK_PIC_P_COD_CLI_4] B ON A.DEBTID = B.DebtID

SELECT A.* 
into AUXSRC.dbo.TMK_Carga_PromParc_2
from [10.206.4.14].[TMK].[dbo].STDPIC_Carga_PromParc A
join AUXSRC.dbo.TMK_Carga_Promessas_2 B on A.ArrangementId = B.ArrangementId