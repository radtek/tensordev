-- -----------------------------------------------------------------------------------
-- File Name    : rman_controlfile_enqueue.sql
-- Description  : Identifying RMAN Controlfile autobackup enqueue locks
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_controlfile_enqueue.sql
-- Last Modified: 05/11/2014
-- -----------------------------------------------------------------------------------
set lines 180 pages 10000
col username format a10
col program format a20
col module format a20
col action format a20
col "Logon" format a20
SELECT l.inst_id, s.sid, s.serial#, username AS "User", program, module, action, to_char(logon_time, 'DD/MM/YYYY HH24:MM') "Logon"
FROM gv$session s, gv$enqueue_lock l
WHERE l.sid=s.sid and l.type='CF' AND l.id1=0 and l.id2=2;
