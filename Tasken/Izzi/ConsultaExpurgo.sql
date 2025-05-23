SELECT SUM(RegistrosExcluidos) FROM Log_Expurgo_Aciona_AcionaVelho WHERE TABELA = 'ACIONA_VELHO' AND ID >= 13392  ORDER BY ID DESC

SELECT COUNT(1) FROM ACIONA_VELHO AS A      
            JOIN CAD_ACIONAMENTO AS B ON A.COD_ACIONAMENTO = B.COD_ACIONAMENTO      
            WHERE       
                A.COD_RECUP = 1      
                AND B.CLASSIFICACAO_ACIONAMENTO = 0      
                AND A.DATA_ACIONA < '2024-01-01'