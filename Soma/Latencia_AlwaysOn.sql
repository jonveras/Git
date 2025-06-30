SELECT 
    ag.name AS AGName,
    ar.replica_server_name,
    db_name(dhdr.database_id) AS DatabaseName,
    dhdr.last_commit_time AS PrimaryLastCommitTime,
    dhs.last_commit_time AS SecondaryLastCommitTime,
    DATEDIFF(SECOND, dhs.last_commit_time, dhdr.last_commit_time) AS ReplicationLag_seconds
FROM 
    sys.dm_hadr_database_replica_states AS dhdr
JOIN 
    sys.availability_groups AS ag ON dhdr.group_id = ag.group_id
JOIN 
    sys.availability_replicas AS ar ON dhdr.replica_id = ar.replica_id
JOIN 
    sys.dm_hadr_database_replica_states AS dhs 
    ON dhdr.group_id = dhs.group_id 
    AND dhdr.database_id = dhs.database_id
WHERE 
    dhdr.is_primary_replica = 1 
    AND dhs.is_primary_replica = 0;
