DECLARE @StartTime datetime
SELECT @StartTime = DATEADD(ms, -sample_ms, GETDATE()) FROM sys.dm_io_virtual_file_stats(1, 1)

SELECT			@StartTime AS StartTime,
				object_name(i.object_id) AS TableName, 
				i.name AS IndexName,
				s.user_updates AS UserUpdates, 
				s.user_seeks AS UserSeeks, 
				s.user_scans AS UserScans, 
				s.user_lookups AS UserLookups
FROM			sys.indexes i
LEFT OUTER JOIN	sys.dm_db_index_usage_stats s 
ON				s.object_id = i.object_id
AND				i.index_id = s.index_id
AND				s.database_id = db_id()
WHERE			objectproperty(i.object_id, 'IsIndexable') = 1
AND				objectproperty(i.object_id, 'IsIndexed') = 1
AND				s.index_id is not null
--AND s.user_updates > 0
--OR (s.user_updates > 0 and s.user_seeks = 0 and s.user_scans = 0 and s.user_lookups = 0)
--ORDER BY object_name(i.object_id) ASC
ORDER BY		ISNULL(s.user_seeks, 0) + ISNULL(s.user_scans, 0) + ISNULL(s.user_lookups, 0) ASC, 
				s.user_updates DESC