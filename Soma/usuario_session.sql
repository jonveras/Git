SELECT 
    s.session_id,
    s.login_name,
    s.host_name,
    c.client_net_address AS IP,
    s.program_name,
    s.login_time
FROM sys.dm_exec_sessions s
JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
WHERE s.is_user_process = 1 and s.login_name like '%fernando.pinheiro%'
ORDER BY s.login_time DESC;