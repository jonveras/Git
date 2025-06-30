--LOG WHOISACTIVE
SELECT 
    [Dt_Log]
    ,[dd hh:mm:ss.mss]
    ,[database_name]
    ,[session_id]
    ,[blocking_session_id]
    ,CONVERT(NVARCHAR(MAX), [sql_text]) AS sql_text
    ,[login_name]
    ,[wait_info]
    ,[status]
    ,[percent_complete]
    ,[host_name]
    ,CONVERT(NVARCHAR(MAX), [sql_command]) AS sql_command
    ,[CPU]
    ,[reads]
    ,[writes]
    ,[Program_Name]
FROM 
    Resultado_WhoisActive 
order by 
    Dt_Log

--LOG Contadores
SELECT Nm_Contador,Dt_Log,Valor
FROM TaskenMaintDB..Contador A 
	JOIN TaskenMaintDB..Registro_Contador B ON A.Id_Contador = B.Id_Contador
ORDER BY DT_LOG
--BatchRequests = transações por segundo
--User_Connection = conexões no banco
--CPU = % consumo de cpu do servidor
--Page Life Expectancy: espectativa de vida em segundos de uma pagina na memoria do sql server (5000 = BOM / 1000 = RAZOAVEL / <300 = BAIXO)