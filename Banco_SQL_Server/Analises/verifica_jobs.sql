SELECT  
	'Occurs ' + 
    CASE 
        WHEN s.freq_type = 1 THEN 'once' 
        WHEN s.freq_type = 4 THEN 'every day'
        WHEN s.freq_type = 8 THEN 'every week on' + 
            STUFF(
                CASE WHEN s.freq_interval & 1  > 0 THEN ', Sunday'   ELSE '' END +
                CASE WHEN s.freq_interval & 2  > 0 THEN ', Monday'   ELSE '' END +
                CASE WHEN s.freq_interval & 4  > 0 THEN ', Tuesday'  ELSE '' END +
                CASE WHEN s.freq_interval & 8  > 0 THEN ', Wednesday' ELSE '' END +
                CASE WHEN s.freq_interval & 16 > 0 THEN ', Thursday' ELSE '' END +
                CASE WHEN s.freq_interval & 32 > 0 THEN ', Friday'   ELSE '' END +
                CASE WHEN s.freq_interval & 64 > 0 THEN ', Saturday' ELSE '' END, 
                1, 2, '') + 
            ' every ' + CAST(s.freq_recurrence_factor AS VARCHAR) + ' week(s)'
        WHEN s.freq_type = 16 THEN 'on day ' + CAST(s.freq_interval AS VARCHAR) + ' of the month'
        WHEN s.freq_type = 32 THEN 'on the ' +
            CASE s.freq_relative_interval
                WHEN 1 THEN 'First' WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' 
                WHEN 4 THEN 'Fourth' WHEN 5 THEN 'Last' ELSE '' END + ' ' +
            CASE s.freq_interval
                WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday'
                WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
                WHEN 7 THEN 'Saturday' WHEN 8 THEN 'Day' WHEN 9 THEN 'Weekday'
                WHEN 10 THEN 'Weekend Day' ELSE '' END + ' of the month'
        ELSE 'Unknown Frequency'
    END + 
    CASE 
        WHEN s.freq_subday_type = 1 THEN ' at ' + FORMAT(DATEADD(SECOND, s.active_start_time % 100 + ((s.active_start_time / 100) % 100) * 60 + (s.active_start_time / 10000) * 3600, 0), 'HH:mm:ss')
        WHEN s.freq_subday_type IN (2, 4, 8) THEN 
            ' every ' + CAST(s.freq_subday_interval AS VARCHAR) + 
            CASE s.freq_subday_type 
                WHEN 2 THEN ' second(s)'
                WHEN 4 THEN ' minute(s)'
                WHEN 8 THEN ' hour(s)' 
                ELSE '' END
        ELSE ''
    END + 
    CASE 
        WHEN s.active_end_time > 0 THEN 
            ' between ' + FORMAT(DATEADD(SECOND, s.active_start_time % 100 + ((s.active_start_time / 100) % 100) * 60 + (s.active_start_time / 10000) * 3600, 0), 'HH:mm:ss') + 
            ' and ' + FORMAT(DATEADD(SECOND, s.active_end_time % 100 + ((s.active_end_time / 100) % 100) * 60 + (s.active_end_time / 10000) * 3600, 0), 'HH:mm:ss')
        ELSE ''
    END + 
    '.' AS ScheduleDescription,
    j.name AS JobName,
	j.job_id as JobId,
	j.enabled AS IsActive,
    h.run_date AS LastRunDate,
    h.run_time AS LastRunTime,
    CASE h.run_status  
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
    END AS RunStatus
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
ORDER BY h.run_date DESC, h.run_time DESC;
