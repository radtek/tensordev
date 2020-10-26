-- -----------------------------------------------------------------------------------
-- File Name    : sql_executing_session_01.sql
-- Description  : Relaciona um processo e o último comando SQL que foi executado
-- Requirements : Access to the DBA views.
-- Call Syntax  : @sql_executing_session_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
col OSUSER format a20
col USUARIO format a30
col SQL_TEXT for a100
select OSUSER, SUBSTR(s.USERNAME,1,10) USUARIO, q.SQL_TEXT
from v$sql q, v$session s
where s.SQL_ADDRESS=q.ADDRESS
--and username = 'PROD_JD'
and s.sid = &server_id;
