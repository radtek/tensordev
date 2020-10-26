-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_02.sql
-- Description  : Comando SELECT para verificar os Wait Events ociosos (idle)
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_02.sql
-- Last Modified: 08/04/2014
-- -----------------------------------------------------------------------------------

set lines 180
col NAME format a60

SELECT NAME,
       WAIT_CLASS
FROM V$EVENT_NAME
WHERE WAIT_CLASS = 'Idle'
ORDER BY NAME;
