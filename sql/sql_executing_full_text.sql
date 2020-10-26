-- -----------------------------------------------------------------------------------
-- File Name    : sql_executing_full_text.sql
-- Description  : Displays all the SQL Text for a session.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @sql_executing_full_text.sql
-- Last Modified: 14/02/2013
-- -----------------------------------------------------------------------------------
PROMPT
PROMPT Displays all the SQL Text for a session by SQL_ID
PROMPT

undefine sql_id
set lines 180
set pages 10000
set long 100000000

select SQL_FULLTEXT
from V$SQL
where SQL_ID = '&&sql_id'
/
