-- -----------------------------------------------------------------------------------
-- File Name    : db_fragmented_tables.sql
-- Description  : This script reports the table that is highly fragmented
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_fragmented_tables.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT SEGMENT_NAME TABLE_NAME , COUNT(*) EXTENTS
FROM DBA_SEGMENTS
WHERE OWNER NOT IN ('SYS', 'SYSTEM')
GROUP BY SEGMENT_NAME
HAVING COUNT(*) = (SELECT MAX( COUNT(*) ) 
FROM DBA_SEGMENTS
GROUP BY SEGMENT_NAME);
