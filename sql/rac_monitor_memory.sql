-- -----------------------------------------------------------------------------------
-- File Name    : rac_monitor_memory.sql
-- Description  : Displays memory allocations for the current database sessions for 
--                the whole RAC
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_monitor_memory.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN USERNAME FORMAT A20
COLUMN MODULE FORMAT A20

SELECT A.INST_ID,
       NVL(A.USERNAME,'(ORACLE)') AS USERNAME,
       A.MODULE,
       A.PROGRAM,
       TRUNC(B.VALUE/1024) AS MEMORY_KB
FROM GV$SESSION A,
     GV$SESSTAT B,
     GV$STATNAME C
WHERE A.SID = B.SID
  AND A.INST_ID = B.INST_ID
  AND B.STATISTIC# = C.STATISTIC#
  AND B.INST_ID = C.INST_ID
  AND C.NAME = 'SESSION PGA MEMORY'
  AND A.PROGRAM IS NOT NULL
ORDER BY B.VALUE DESC;
