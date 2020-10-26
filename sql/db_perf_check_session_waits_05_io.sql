-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_05_io.sql
-- Description  : Comandos SELECT para verificar os Wait Events de I/O
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_05_io.sql
-- Last Modified: 08/04/2014
-- -----------------------------------------------------------------------------------

set lines 180
set pages 10000

col    WAIT_CLASS    format a12
col    NAME          format a60

SELECT WAIT_CLASS,
       NAME
FROM V$EVENT_NAME
WHERE WAIT_CLASS IN ('User I/O',
                     'System I/O'
					)
ORDER BY 1 DESC
/
