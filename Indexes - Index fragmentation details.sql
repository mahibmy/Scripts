DECLARE @DatabaseID int
SET @DatabaseID = DB_ID()

SELECT		dbschemas.[name] AS 'Schema', 
			dbtables.[name] AS 'Table', 
			dbindexes.[name] AS 'Index',
			partition_number,
			(CASE ds.type_desc WHEN 'PARTITION_SCHEME' THEN 1 ELSE 0 END) AS paritioned_ind,
			indexstats.avg_fragmentation_in_percent * indexstats.page_count AS [fragmentation_wt],
			indexstats.avg_fragmentation_in_percent,
			indexstats.page_count,
			STATS_DATE(dbindexes.[object_id], dbindexes.index_id) AS statsdate
FROM		sys.dm_db_index_physical_stats (@DatabaseID, NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN	sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
INNER JOIN	sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN	sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND			indexstats.index_id = dbindexes.index_id
INNER JOIN	sys.data_spaces ds 
ON			dbindexes.data_space_id = ds.data_space_id
WHERE		indexstats.database_id = @DatabaseID
AND			dbindexes.[name] IS NOT NULL
AND			indexstats.page_count > 50
AND			avg_fragmentation_in_percent > 5
ORDER BY	avg_fragmentation_in_percent * page_count DESC

--SELECT		a.object_id, 
--			a.index_id, 
--			partition_number,
--			avg_fragmentation_in_percent, 
--			(CASE ds.type_desc WHEN 'PARTITION_SCHEME' THEN 1 ELSE 0 END) AS paritioned_ind
----			used
--FROM		sys.dm_db_index_physical_stats (@currentDdbId, NULL, NULL , NULL, 'LIMITED') a
--INNER JOIN	sys.indexes si 
--ON			a.object_id = si.object_id
--AND			a.index_id = si.index_id
--INNER JOIN	sys.data_spaces ds 
--ON			si.data_space_id = ds.data_space_id
--WHERE		a.index_id > 0
--AND			page_count > 50

--select * from master..sysprocesses where dbid = db_id()

/*
SELECT OBJECT_NAME(id),name,STATS_DATE(id, indid),rowmodctr 
FROM sys.sysindexes 
WHERE STATS_DATE(id, indid)<=DATEADD(DAY,1,GETDATE()) 
AND rowmodctr>0 
AND id IN (SELECT object_id FROM sys.tables) 
order by rowmodctr desc
GO
*/
