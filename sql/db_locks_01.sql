-- -----------------------------------------------------------------------------------
-- File Name    : db_locks_01.sql
-- Description  : Verifying database locks
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_locks_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid sess,
id1, id2, lmode, request, type
FROM V$LOCK
WHERE (id1, id2, type) IN (SELECT id1, id2, type FROM V$LOCK WHERE request>0)
ORDER BY id1, request;
