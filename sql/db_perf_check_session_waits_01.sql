-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_01.sql
-- Description  : Comando SELECT para verificar os Wait Events das sessões atuais
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_01.sql
-- Last Modified: 11/04/2014
-- -----------------------------------------------------------------------------------

set lines 180
set pages 10000

col    SERIAL      format 9999999
col    EVENT       format a48
col    USERNAME    format a20
col    OSUSER      format a20
col    PROGRAM     format a16
col    MACHINE     format a16
col    WAIT_CLASS  format a14

SELECT S.SID, 
	   S.SERIAL# SERIAL,
       SUBSTR(W.EVENT,1,47) AS EVENT,
	   W.SECONDS_IN_WAIT,
	   SUBSTR(S.PROGRAM,1,15) AS PROGRAM,
	   SUBSTR(S.MACHINE,1,15) AS MACHINE,
	   SUBSTR(S.USERNAME,1,19) AS USERNAME,
	   SUBSTR(S.OSUSER,1,19) AS OSUSER,
	   W.WAIT_CLASS
FROM V$SESSION_WAIT W,
     V$SESSION S 
WHERE S.SID = W.SID
  AND W.EVENT NOT LIKE '%idle%'
ORDER BY W.SECONDS_IN_WAIT DESC
/
