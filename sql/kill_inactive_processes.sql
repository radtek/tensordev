-- -----------------------------------------------------------------------------------
-- File Name    : kill_inactive_processes.sql
-- Description  : Matando sessões inativas no banco de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @kill_inactive_processes.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
prompt
prompt This script query all inactive and sniped sessions in the database and give a output with the command to kill them all
prompt

-- Para ambientes em RAC
select 'alter system kill session '''||sid||','||serial#||',@'||inst_id||''' immediate;' as KILL_SESSIONS from gv$session where status in ('SNIPED','INACTIVE');

-- Para ambientes Standalone
-- select 'alter system kill session '''||SID||','||serial#||''' immediate;' as KILL_SESSIONS from v$session where status in ('SNIPED','INACTIVE');
