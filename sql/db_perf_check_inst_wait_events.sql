-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_inst_wait_events.sql
-- Description  : Verificacao dos maiores Wait Events das sessões atuais ativas
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_inst_wait_events.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
col USERNAME format a10
col EVENT format a40
col USERNAME format a20
col PROGRAM format a22
col WAIT_CLASS format a20

SELECT s.SID, 
       s.USERNAME, 
	   SUBSTR(s.PROGRAM,1,20) PROGRAM, 
	   e.EVENT, 
	   SUM(e.TOTAL_TIMEOUTS) AS TOTAL_TIMEOUTS, 
	   e.TIME_WAITED/100 AS TIME_WAITED_IN_SEC, 
	   e.WAIT_CLASS
FROM V$SESSION s, V$SESSION_EVENT e
WHERE s.SID = e.SID 
  AND e.EVENT NOT IN ('SQL*Net message from client',
                    'SQL*Net message to client',
                    'pmon timer', 'smon timer',
                    'rdbms ipc message', 'jobq slave wait',
                    'rdbms ipc reply', 'i/o slave wait',
                    'PX Deq: Execution Msg')
  AND e.EVENT NOT LIKE '%idle%'
  AND e.WAIT_CLASS NOT LIKE '%Idle%'
  AND s.STATUS = 'ACTIVE'
GROUP BY s.SID, s.USERNAME, s.PROGRAM, e.EVENT, e.TIME_WAITED, e.WAIT_CLASS
ORDER BY 6;
