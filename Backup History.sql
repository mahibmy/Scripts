SELECT 
    s.database_name,
    m.physical_device_name,
    CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' MB' AS bkSize,
    CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' Seconds' AS TimeTaken,
    s.backup_start_date,
    CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
    CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
    CASE s.[type] 
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction Log'
    END AS BackupType,
    CASE 
        WHEN s.is_copy_only = 1 THEN 'Yes'
        ELSE 'No'
    END AS IsCopyOnly,
    s.server_name,
    s.recovery_model
FROM 
    msdb.dbo.backupset s
INNER JOIN 
    msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
--WHERE s.database_name = DB_NAME() -- Uncomment for current DB only
ORDER BY 
    s.backup_start_date DESC, 
    s.backup_finish_date
GO