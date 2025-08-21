SELECT 
    r.session_id,
    r.status,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    c.client_net_address,
    s.host_name,
    s.login_name,
    DB_NAME(r.database_id) AS database_name,
    t.text AS running_query
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s 
    ON r.session_id = s.session_id
JOIN sys.dm_exec_connections c 
    ON r.session_id = c.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.wait_type = 'ASYNC_NETWORK_IO' and host_name like 'inthub%'
ORDER BY r.wait_time DESC;