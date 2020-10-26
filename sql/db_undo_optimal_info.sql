-- -----------------------------------------------------------------------------------
-- File Name    : db_undo_optimal_info.sql
-- Description  : It shows the optimal undo_retention size to be increased
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_undo_optimal_info.sql
-- Last Modified: 20/11/2013
-- -----------------------------------------------------------------------------------
set lines 180

col "OPTIMAL UNDO RETENTION [Sec]" format 9999999999
col "UNDO RETENTION [Sec]"         format a40

SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
       SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
       ROUND((d.undo_size / (to_number(f.value) *
       g.undo_block_per_sec))) "OPTIMAL UNDO RETENTION [Sec]"
FROM (
      SELECT SUM(a.bytes) undo_size
      FROM v$datafile a, v$tablespace b, dba_tablespaces c
      WHERE c.contents = 'UNDO'
        AND c.status = 'ONLINE'
        AND b.name = c.tablespace_name
        AND a.ts# = b.ts#
     ) d,
      v$parameter e,
      v$parameter f,
    (
      SELECT MAX(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec
      FROM v$undostat
     ) g
WHERE e.name = 'undo_retention'
AND f.name = 'db_block_size'
/
