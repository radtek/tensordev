-- -----------------------------------------------------------------------------------
-- File Name    : db_locks_04.sql
-- Description  : Verifying database locks
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_locks_04
-- Last Modified: 12/09/2019
-- -----------------------------------------------------------------------------------

set linesize 200 pages 9000 colsep |;

column  sid             format  999999;
column  rbs             format  999;
column  slot            format  9999;
column  seq             format  9999999;
column  lmode           format  99999;
column  request         format  9999999;
column  username        format  a15;
column  object_name     format  a20;
column  ctime           format  999999 ;
column object_type 	    format a16;

set feedback on;

prompt Qui lock qui;

SELECT (SELECT username FROM v$session WHERE sid=a.sid) blocker,
        a.sid, ' is blocking ',
        (SELECT username FROM v$session WHERE sid=b.sid) blockee,
        b.sid
FROM  gv$lock a, gv$lock b
WHERE  a.block = 1
  AND  b.request > 0
  AND  a.id1 = b.id1
  AND  a.id2 = b.id2
ORDER BY a.sid ;

set feedback off;
