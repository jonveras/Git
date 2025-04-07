SELECT 
    j.job_id,
    j.name AS job_name,
    s.step_id,
    s.step_name,
    s.command
FROM 
    msdb.dbo.sysjobs j
INNER JOIN 
    msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
WHERE 
    s.command LIKE '%GS_FORECAST_FINAL_IMPORTADO%';