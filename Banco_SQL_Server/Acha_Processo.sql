--Acha qual objeto contem o nome
SELECT 
    o.name AS objeto,
    o.type_desc AS tipo,
    s.name AS schema_nome,
    m.definition AS texto
FROM 
    sys.sql_modules m
JOIN 
    sys.objects o ON m.object_id = o.object_id
JOIN 
    sys.schemas s ON o.schema_id = s.schema_id
WHERE 
    m.definition LIKE '%objeto%'
ORDER BY 
    o.type_desc, o.name;

--Acha qual job contem o nome
SELECT 
    j.name AS nome_job,
    s.step_id,
    s.step_name,
    s.command
FROM 
    msdb.dbo.sysjobs j
JOIN 
    msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
WHERE 
    s.command LIKE '%objeto%'
ORDER BY 
    j.name, s.step_id;