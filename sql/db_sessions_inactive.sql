-- -----------------------------------------------------------------------------------
-- File Name    : db_sessions_inactive.sql
-- Description  : Displays information about inactive database sessions.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sessions_inactive.sql
-- Last Modified: 02/10/2014
-- -----------------------------------------------------------------------------------
set lines 3000;
set pages 10000;

col username format a20
col sid format 99999
col serial format 99999
col status format a8
col osuser format a16
col program format a40
col machine format a40
col logon_time format a20

select username,
       sid,
	   serial# serial,
	   status,
	   osuser,
	   substr(program,1,39) program,
       substr(machine,1,39) machine,
	   TO_CHAR(logon_time,'DD-MON-RRRR HH24:MI:SS') logon_time,
	   sql_id
from gv$session 
where username <> ' '
  and status = 'INACTIVE'
order by logon_time desc
/
