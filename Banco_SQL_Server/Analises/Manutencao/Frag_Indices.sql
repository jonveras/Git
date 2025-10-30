If OBJECT_ID('tempdb..hashtag#tempFragmentation') 
is not null Drop table hashtag#tempFragmentation

CREATE TABLE hashtag#TempFragmentation
([Database] varchar(20),
[TableName] varchar(50),
[IndexName] varchar(50),
[FragmentationPercent] decimal(5,2))

INSERT INTO hashtag#TempFragmentation
EXEC sp_msforeachdb 
'USE [?];

Select * FROM (
SELECT 
 DB_NAME() AS [Database]
 ,OBJECT_NAME(s.[object_id]) AS [TableName]
 ,i.name AS [IndexName]
 ,ROUND(avg_fragmentation_in_percent,2) AS [FragmentationPercent]
FROM sys.dm_db_index_physical_stats(db_id(),null, null, null, null) s
INNER JOIN sys.indexes i WITH (NOLOCK) ON s.object_id = i.object_id
 AND s.index_id = i.index_id
INNER JOIN sys.objects o WITH (NOLOCK) ON i.object_id = O.object_id 
WHERE s.database_id = DB_ID()
and s.database_id > 4
AND i.name IS NOT NULL 
AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0 ) as X
'

select *
from hashtag#TempFragmentation
order by FragmentationPercent desc