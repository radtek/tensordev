-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_08.sql
-- Description  : Verifying sessions that are in wait state
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_08.sql
-- Last Modified: 08/04/2012
-- -----------------------------------------------------------------------------------

SELECT W.SID, W.EVENT, W.SECONDS_IN_WAIT, SQL.SQL_TEXT 
FROM V$SESSION_WAIT W, V$SESSION S, V$PROCESS P, V$SQLTEXT SQL 
WHERE W.SID = S.SID AND
 S.PADDR = P.ADDR AND
 SQL.ADDRESS = S.SQL_ADDRESS AND
 SQL.HASH_VALUE = S.SQL_HASH_VALUE AND
 W.WAIT_CLASS != 'Idle' 
ORDER BY W.SECONDS_IN_WAIT, W.SID, SQL.PIECE;
