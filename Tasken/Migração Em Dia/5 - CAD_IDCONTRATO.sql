INSERT INTO CAD_IDCONTRATO(CONTRATO_ORIGINAL, CPF_DEV, DATA_INCLUSAO)
SELECT  
convert(varchar,A.CONTRATO_ORIGINAL),
A.CPF COLLATE SQL_Latin1_General_CP1_CI_AS,
'20241111'
FROM CAD_DEVF_CARREFOUR A
WHERE NOT EXISTS (SELECT 1 FROM CAD_IDCONTRATO B WHERE B.CONTRATO_ORIGINAL = convert(varchar,A.NUM_CONTRATO) collate SQL_Latin1_General_CP1_CI_AS)
--AND B.CPF_DEV = A.CPF COLLATE SQL_Latin1_General_CP1_CI_AS)

--SELECT * FROM CAD_DEVF_RIACHUELO_CAR11
--SELECT * FROM CAD_IDCONTRATO WHERE CPF_DEV = '5216374736'
--SELECT * FROM CAD_DEVP WHERE CONTRATO_FIN = '44407886ID'

--DELETE
--SELECT *
--INTO CAD_IDCONTRATO_BKP_SEMPARAR_20240825
--FROM CAD_IDCONTRATO WHERE DATA_INCLUSAO = '20240825'

--44082481ID