-- -----------------------------------------------------------------------------------
-- File Name    : db_locks.sql
-- Description  : Verifying database locks
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_locks.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT  (SELECT trim(s1.USERNAME)||'-'||trim(s1.osuser)||'-status:'||status||'-spid:'||p1.spid
         FROM V$SESSION s1, v$process p1
         WHERE s1.SID = A.SID and s1.paddr=p1.addr) ||'-sid:'||A.SID||     '- BLOQUEANDO:'||
        (SELECT trim(USERNAME)||'-'||trim(osuser)
         FROM V$SESSION
         WHERE  SID=B.SID) ||'-sid:'||B.SID
FROM V$LOCK A, V$LOCK B
WHERE A.BLOCK = 1
  AND B.REQUEST > 0
  AND A.ID1 = B.ID1
  AND A.ID2 = B.ID2;
