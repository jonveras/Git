SELECT  
    j.name AS JobName,
    j.enabled AS IsActive,
    h.run_date AS LastRunDate,
    h.run_time AS LastRunTime,
    h.run_status,
    CASE h.run_status  
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
    END AS RunStatus,
    s.name AS ScheduleName,
    CASE 
        WHEN s.freq_type = 1 THEN 'One Time Execution'
        WHEN s.freq_type = 4 THEN 'Daily'
        WHEN s.freq_type = 8 THEN 'Weekly'
        WHEN s.freq_type = 16 THEN 'Monthly (Specific Day)'
        WHEN s.freq_type = 32 THEN 'Monthly (Relative, e.g., First Monday)'
        WHEN s.freq_type = 64 THEN 'When SQL Agent Starts'
        WHEN s.freq_type = 128 THEN 'When CPU Idle'
        ELSE 'Unknown'
    END + 
    CASE 
        WHEN s.freq_type IN (8, 16, 32) THEN ' - ' + 
            CASE 
                WHEN s.freq_type = 8 THEN 'Every ' + CAST(s.freq_interval AS VARCHAR) + ' days' 
                WHEN s.freq_type = 16 THEN 'On day ' + CAST(s.freq_interval AS VARCHAR) + ' of the month'
                WHEN s.freq_type = 32 THEN 'On ' + 
                    CASE s.freq_relative_interval
                        WHEN 1 THEN 'First' WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' 
                        WHEN 4 THEN 'Fourth' WHEN 5 THEN 'Last' ELSE '' END + ' ' +
                    CASE s.freq_interval
                        WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday'
                        WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
                        WHEN 7 THEN 'Saturday' WHEN 8 THEN 'Day' WHEN 9 THEN 'Weekday'
                        WHEN 10 THEN 'Weekend Day' ELSE '' END
            END
        ELSE ''
    END + 
    CASE 
        WHEN s.freq_subday_type = 1 THEN ' at ' + STUFF(STUFF(RIGHT('000000' + CAST(s.active_start_time AS VARCHAR), 6), 5, 0, ':'), 3, 0, ':') 
        WHEN s.freq_subday_type = 2 THEN ' every ' + CAST(s.freq_subday_interval AS VARCHAR) + ' seconds'
        WHEN s.freq_subday_type = 4 THEN ' every ' + CAST(s.freq_subday_interval AS VARCHAR) + ' minutes'
        WHEN s.freq_subday_type = 8 THEN ' every ' + CAST(s.freq_subday_interval AS VARCHAR) + ' hours'
        ELSE ''
    END AS ScheduleDescription
FROM msdb.dbo.sysjobs j  
JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id  
LEFT JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id  
LEFT JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id  
WHERE j.enabled = 1  -- Apenas jobs ativos
AND h.run_status = 0 -- Apenas jobs que falharam
AND h.instance_id = (
    SELECT MAX(h2.instance_id) 
    FROM msdb.dbo.sysjobhistory h2
    WHERE h2.job_id = h.job_id
) -- Pega o último histórico do job
ORDER BY h.run_date DESC, h.run_time DESC