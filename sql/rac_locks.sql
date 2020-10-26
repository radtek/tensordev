-- -----------------------------------------------------------------------------------
-- File Name    : rac_locks.sql
-- Description  : Verifying database locks in a RAC environment
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_locks.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set numwidth 10
column state format a7 tru
column event format a25 tru
column last_sql format a40 tru
select sw.inst_id, sw.sid, sw.state, sw.event, sw.seconds_in_wait seconds, 
sw.p1, sw.p2, sw.p3, sa.sql_text last_sql
from gv$session_wait sw, gv$session s, gv$sqlarea sa
where sw.event not in 
('rdbms ipc message','smon timer','pmon timer',
'SQL*Net message from client','lock manager wait for remote message',
'ges remote message', 'gcs remote message', 'gcs for action', 'client message', 
'pipe get', 'null event', 'PX Idle Wait', 'single-task message', 
'PX Deq: Execution Msg', 'KXFQ: kxfqdeq - normal deqeue', 
'listen endpoint status','slave wait','wakeup time manager')
and sw.seconds_in_wait > 0 
and (sw.inst_id = s.inst_id and sw.sid = s.sid)
and (s.inst_id = sa.inst_id and s.sql_address = sa.address)
order by seconds desc;
