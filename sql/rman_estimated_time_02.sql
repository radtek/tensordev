-- -----------------------------------------------------------------------------------
-- File Name    : rman_estimated_time_02.sql
-- Description  : Estimativa de tempo Backup/Restore Rman
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_estimated_time_02.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT SID, SERIAL#, CONTEXT, SOFAR, TOTALWORK, ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM V$SESSION_LONGOPS
WHERE OPNAME LIKE 'RMAN%'
      AND OPNAME NOT LIKE '%aggregate%'
      AND TOTALWORK != 0
      AND SOFAR <> TOTALWORK;
