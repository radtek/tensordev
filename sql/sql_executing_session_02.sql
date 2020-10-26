-- -----------------------------------------------------------------------------------
-- File Name    : sql_executing_session_02.sql
-- Description  : Para saber se uma Procedure ou Package está sendo executada no banco 
--                de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @sql_executing_session_02.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select x.sid 
from v$session x, v$sqltext y
where x.sql_address = y.address
      and y.sql_text like '%&&sql_text%';
