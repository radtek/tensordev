-- -----------------------------------------------------------------------------------
-- File Name    : db_undo_longest_running_query.sql
-- Description  : Find out longest running query in the v$undostat
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_undo_longest_running_query.sql
-- Last Modified: 20/11/2013
-- -----------------------------------------------------------------------------------
set lines 200
select max(MAXQUERYLEN) AS "Longest Running (sec)"
from v$undostat;
