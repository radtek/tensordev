-- -----------------------------------------------------------------------------------
-- File Name    : db_locks_02.sql
-- Description  : Verifying database locks
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_locks_02.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT hold.sid hold_sid, hold.action, hold.inst_id,hold.sql_hash_value, round((hold.LAST_CALL_ET) / 60 / 60, 2) "Last Call ET Horas", count(hold.sid)  waiting_sessions
FROM gv$session_wait sw, gv$session wait, GV$LOCK l, gv$session hold
WHERE sw.event = 'enqueue'
  AND wait.sid = sw.sid
  AND wait.inst_id = sw.inst_id
  AND l.id1 = sw.p2
  AND l.id2 = sw.p3
  AND l.block <> 0
  AND hold.sid = l.sid
  AND hold.inst_id = l.inst_id
--AND           hold.LAST_CALL_ET > 1800 (30 min)
GROUP BY hold.sid, hold.action, hold.inst_id, hold.sql_hash_value, hold.last_call_et;
