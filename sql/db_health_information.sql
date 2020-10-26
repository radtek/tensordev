-- -----------------------------------------------------------------------------------
-- File Name    : db_health_information.sql
-- Description  : Script to monitor health of Oracle Database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_health_information.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------

PROMPT This script will generate a log called db_health_information.log at /tmp directory
REM Check for any broken Oracle Jobs
REM
SET PAGES 999 LINES 80 PAU OFF TIME ON HEADING ON FEEDBACK OFF TERMOUT OFF
SET TRIMS ON
SPOOL /tmp/db_health_information.log
COLUMN job    FORMAT 999
COLUMN what   FORMAT a20
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER "These Oracle Jobs Are Broken And Will No Longer Be Executed" SKIP 1
SELECT job, what, last_date, last_sec, next_date, next_sec, failures, broken
FROM   dba_jobs
WHERE  broken = 'Y'
ORDER BY job
/
REM 
REM Check for extensive growth of extents
REM
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER 'Take Care Of The Following Objects : They Are Nearing Extent Limits' SKIP 1
COLUMN owner            FORMAT a12 HEADING 'Owner'
COLUMN tablespace_name  FORMAT a10 HEADING 'TblSpace Name'
COLUMN segment_name     FORMAT a30 HEADING 'Object Name'
COLUMN segment_type     FORMAT a17 HEADING 'Object Type'
COLUMN cnt              FORMAT 990 HEADING 'Extents'
SELECT tablespace_name, segment_name,
       segment_type, COUNT(extent_id) cnt
FROM   dba_extents
WHERE  tablespace_name NOT IN ('TEMP', 'RBS')
GROUP BY owner, tablespace_name, segment_name,segment_type
HAVING COUNT(extent_id) > 150
/
REM
REM Check for Extents that cannot extent
REM
COLUMN owner FORMAT A12
COLUMN segment_name FORMAT A30 
COLUMN segment_type FORMAT A12
COLUMN seg_count FORMAT "999,999"
COLUMN seg_max FORMAT "999,999"
TTITLE 'Segments that Are Sitting on the Maximum Extents Allowable '
SELECT  e.owner, e.segment_name, e.segment_type,
	count(*) seg_count, avg(max_extents) seg_max
FROM  dba_extents e , dba_segments s
WHERE  e.segment_name = s.segment_name
AND  e.owner        = s.owner
AND    e.segment_type != 'ROLLBACK'
GROUP BY  e.owner, e.segment_name, e.segment_type
HAVING COUNT(*) = AVG(max_extents)
/
REM
REM Check for available free space
REM
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER 'Take Care Of The Following Tablespaces : They Are Nearing Space Limits' SKIP 1
COLUMN tsname        FORMAT a12
COLUMN extents       FORMAT 9999
COLUMN bytes         FORMAT 999,999,999
COLUMN largest       FORMAT 999,999,999
COLUMN Tot_Size      FORMAT 9,999,999 HEADING "TOTAL(M)"
COLUMN Tot_Free      FORMAT 9,999,999 HEADING "FREE (M)"
COLUMN Pct_Free      FORMAT 999 HEADING "FREE %"
COLUMN Fragments     FORMAT 999,999
COLUMN Large_Ext     FORMAT 9,999,999 HEADING "BIG EXT(M)"
SELECT a.tablespace_name TSNAME, SUM(a.tots)/1048576 Tot_Size,
       SUM(a.sumb)/1048576 Tot_Free,
       SUM(a.sumb)*100/sum(a.tots) Pct_Free,
       SUM(a.largest)/1048576 Large_Ext, SUM(a.chunks) Fragments
FROM   (SELECt tablespace_name, 0 tots, SUM(bytes) sumb,
               MAX(bytes) largest, COUNT(*) chunks
        FROM   dba_free_space a
        GROUP BY tablespace_name
        UNION
        SELECT tablespace_name, SUM(bytes) tots, 0, 0, 0 
	FROM   dba_data_files
        GROUP BY tablespace_name) a
GROUP BY a.tablespace_name
HAVING SUM(a.sumb)/1048576 < 10
AND SUM(a.sumb)*100/sum(a.tots) < 30
/
REM
REM Check for Disabled Triggers
REM
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER 'Verify The Following Triggers : All Are Disabled' SKIP 1
COLUMN trigger_name   FORMAT a35
COLUMN table_name     FORMAT a35
SELECT owner || '.' || trigger_name trigger_name,
       table_owner || '.' || table_name table_name
FROM   dba_triggers
WHERE  status = 'DISABLED'
ORDER BY owner, table_name
/
REM 
REM Check for Invalid Objects
REM
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER "Verify The Following Objects : All Are Invalid" SKIP 1 CENTER "(Drop if not required by the Application!)" SKIP 1
COLUMN object_name     FORMAT a35
COLUMN object_type     FORMAT a15
COLUMN last_ddl_time   FORMAT a20
SELECT owner || '.' || object_name object_name, object_type,
       to_char(last_ddl_time,'MM-DD-YYYY HH24:MI:SS') last_ddl_time
FROM   dba_objects
WHERE  status = 'INVALID'
ORDER BY owner, object_type
/
REM
REM Check for Users Defaulted to SYSTEM Tablespace
REM
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER 'Change The Following Schema Tablespaces Apropriately' SKIP 1
COLUMN default_tablespace   FORMAT a25
COLUMN temporary_tablespace FORMAT a25
COLUMN username             FORMAT a15
SELECT username, default_tablespace, temporary_tablespace
FROM   dba_users
WHERE  (default_tablespace = 'SYSTEM'
OR     temporary_tablespace = 'SYSTEM')
AND    username != 'SYS'
/
REM 
REM Check for objects created/modified under SYS or SYSTEM Schema in 24 Hours
REM
TTITLE LEFT "**********************************************************************" SKIP 1 CENTER 'Verify The Following SYS / SYSTEM Objects' SKIP 1 CENTER '(These Objects Changed In The Last 24 Hours)' SKIP 1
COLUMN object_name     FORMAT a35
COLUMN object_type     FORMAT a15
COLUMN last_ddl_time   FORMAT a20
SELECT owner || '.' || object_name object_name, object_type,
       to_char(last_ddl_time,'MM-DD-YYYY HH24:MI:SS') last_ddl_time
FROM   dba_objects
WHERE  last_ddl_time > (sysdate - 1)
AND    owner in ('SYS', 'SYSTEM')
ORDER BY owner, object_type
/
SPOOL OFF
EXIT
REM End of Script
