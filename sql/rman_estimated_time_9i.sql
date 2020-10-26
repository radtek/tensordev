-- -----------------------------------------------------------------------------------
-- File Name    : rman_estimated_time_9i.sql
-- Description  : Estimativa de tempo Backup/Restore Rman em bases 9i
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_estimated_time_9i.sql
-- Last Modified: 10/01/2017
-- -----------------------------------------------------------------------------------

set colsep |
set lines 180 pages 5000

alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col sid format 9999
col opname format a40
col " % DONE" format a10

select sl.sid, 
       sl.serial#,
	   sl.opname OPERATION, 
	   sl.start_time,
       sysdate+(TIME_REMAINING/60/60/24) done_by,
       to_char(100*(sofar/totalwork), '990.9')||'%' " % DONE"
from v$session_longops sl, v$session s
where sl.sid = s.sid
  and sl.serial# = s.serial#
  and sl.sid in (select sid from v$session where module like 'backup%' or module like 'restore%' or module like 'rman%')
  and sofar != totalwork
  and totalwork > 0
/
