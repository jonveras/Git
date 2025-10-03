    /*
     _________________________________
    |                                 |
    | LEMBRAR DE AJUSTAR O START_STEP |
    |_________________________________|
    
     */

--Etapas do Job do Custo Medio para o processo do Nao Realizado
Step 1 - AJUSTE_FILIAIS_ANTES_DO_CUSTO
-- PRIMEIRO STEP 1 ---
UPDATE A SET A.MATRIZ =  'FABULA FILIAL PA'
FROM FILIAIS A
 JOIN PROP_FILIAIS B ON A.FILIAL = B.FILIAL AND B.PROPRIEDADE = '01126'
WHERE B.VALOR_PROPRIEDADE  = 'COMERCIAL'
-- PRIMEIRO STEP 1 --
 
Step 2 - Ajusta data Emissão Entradas não conferidas para o mês vigente
EXEC LX_GS_AJUSTA_ENTRADA_VIRADA_MES_CUSTO_MEDIO
 
Step 3 - ATUALIZAR_CUSTO_MEDIO_MP_PA
UPDATE CM_DATA_FECHAMENTO SET DATA_SALDO_MP = '20171231'
                        GO
                        UPDATE CM_DATA_FECHAMENTO SET DATA_SALDO_PA = '20171231'
                        GO
                        UPDATE PARAMETROS SET VALOR_ATUAL='31/12/2015' WHERE PARAMETRO = 'DATA_BLOQUEIO_MOV_MP'
                        go
                        UPDATE PARAMETROS SET VALOR_ATUAL='31/12/2015' WHERE PARAMETRO = 'DATA_BLOQUEIO_MOV_PA'
                        go
                        EXEC LX_CM_FECHAMENTO_CUSTO_MEDIO 'CM2507R',1
                        go
                   
Step 4 - AJUSTE_FILIAIS_DEPOIS_DO_CUSTO
-- ULTIMO STEP  --
UPDATE A SET A.MATRIZ = 'FABULA - MATRIZ'
FROM FILIAIS A
 JOIN PROP_FILIAIS B ON A.FILIAL = B.FILIAL AND B.PROPRIEDADE = '01126'
-- ULTIMO STEP  --