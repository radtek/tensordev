-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_06.sql
-- Description  : Comandos SELECT para verificar os maiores Wait Events das sessões 
--                atuais, e para verificar os Wait Events de toda a instância
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_06.sql
-- Last Modified: 08/04/2014
-- -----------------------------------------------------------------------------------

set lines 180
PROMPT
PROMPT
PROMPT MAIORES WAIT EVENTS DAS SESSOES ATUAIS
PROMPT
col EVENT format a80
SELECT EVENT, SUM(TOTAL_TIMEOUTS)
FROM V$SESSION_EVENT
WHERE EVENT NOT IN ('SQL*Net message from client',
                    'SQL*Net message to client',
                    'pmon timer', 'smon timer',
                    'rdbms ipc message', 'jobq slave wait',
                    'rdbms ipc reply', 'i/o slave wait',
                    'PX Deq: Execution Msg')
GROUP BY EVENT
ORDER BY 2 DESC;


set lines 180
col EVENT format a80
PROMPT
PROMPT
PROMPT MAIORES WAIT EVENTS DE TODA A INSTANCIA
PROMPT
SELECT EVENT, AVERAGE_WAIT, TOTAL_TIMEOUTS
FROM V$SYSTEM_EVENT
WHERE EVENT NOT IN ('SQL*Net message from client',
                    'SQL*Net message to client',
                    'pmon timer', 'smon timer',
                    'rdbms ipc message', 'jobq slave wait',
                    'rdbms ipc reply', 'i/o slave wait',
                    'PX Deq: Execution Msg')
ORDER BY TOTAL_TIMEOUTS DESC;
