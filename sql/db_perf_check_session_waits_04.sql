-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_04.sql
-- Description  : Comando SELECT para verificar SQL executado por uma sessão
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_04.sql
-- Last Modified: 08/04/2014
-- -----------------------------------------------------------------------------------
set lines 180

col SQL_TEXT format a180

SELECT A.SQL_TEXT
FROM V$SQLTEXT A, V$SESSION B
WHERE A.ADDRESS = B.SQL_ADDRESS
      AND A.HASH_VALUE = B.SQL_HASH_VALUE
      AND B.SID = &SID
ORDER BY PIECE;
