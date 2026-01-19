select 'KILL ' + cast(session_id AS varchar), 
* 
from sys.dm_exec_sessions AS a 
where session_id > 50 and login_name = 'app_somalabs_fat'