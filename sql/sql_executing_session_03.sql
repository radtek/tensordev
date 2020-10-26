-- -----------------------------------------------------------------------------------
-- File Name    : sql_executing_session_03.sql
-- Description  : COMANDOS EM EXECUCAO NAS CONEXOES ATIVAS:
-- Requirements : Access to the DBA views.
-- Call Syntax  : @sql_executing_session_03.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
col "USER" format a12
select distinct s.sid, OSUSER,SUBSTR(s.USERNAME,1,10) as "USER",q.EXECUTIONS,Q.DISK_READS, q.SQL_TEXT
from v$sql q, v$session s
where s.SQL_ADDRESS=q.ADDRESS and s.status='ACTIVE' and s.username is not null;
