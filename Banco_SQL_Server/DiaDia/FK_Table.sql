
SELECT 
	fk.name AS FK_name,
	tp.name AS PrimaryTable,
	ref.name AS ReferencedTable,
	cp.name AS PrimaryColumn,
	cref.name AS ReferencedColumn
FROM 
	sys.foreign_keys AS fk
INNER JOIN 
	sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN 
	sys.tables AS ref ON fk.referenced_object_id = ref.object_id
INNER JOIN 
	sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
	sys.columns AS cp ON fkc.parent_column_id = cp.column_id AND tp.object_id = cp.object_id
INNER JOIN 
	sys.columns AS cref ON fkc.referenced_column_id = cref.column_id AND ref.object_id = cref.object_id
WHERE
	fk.name = 'NOME DA FK'