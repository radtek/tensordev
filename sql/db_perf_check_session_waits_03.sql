-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_03.sql
-- Description  : Comando SELECT para verificar os Wait Events não ociosos das sessões 
--                atuais
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_03.sql
-- Last Modified: 08/04/2014
-- -----------------------------------------------------------------------------------

set lines 180
set pages 10000

col    SERIAL      format 9999999
col    EVENT       format a60
col    USERNAME    format a20
col    OSUSER      format a20
col    PROGRAM     format a16
col    MACHINE     format a16

SELECT S.SID, 
	   S.SERIAL# SERIAL,
       W.EVENT, 
	   W.SECONDS_IN_WAIT,
	   SUBSTR(S.PROGRAM,1,15) AS PROGRAM,
	   SUBSTR(S.MACHINE,1,15) AS MACHINE,
	   SUBSTR(S.USERNAME,1,19) AS USERNAME,
	   SUBSTR(S.OSUSER,1,19) AS OSUSER
FROM V$SESSION_WAIT W,
     V$SESSION S 
WHERE S.SID = W.SID
  AND W.EVENT NOT IN ('SQL*Net message from client',
                      'SQL*Net message to client',
                      'pmon timer', 'smon timer',
                      'rdbms ipc message', 
				   	  'jobq slave wait',
                      'rdbms ipc reply', 
					  'i/o slave wait',
                      'PX Deq: Execution Msg'
					 )
  AND W.EVENT NOT LIKE '%idle%'
ORDER BY SECONDS_IN_WAIT DESC;
