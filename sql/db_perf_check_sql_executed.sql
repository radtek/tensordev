-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_sql_executed.sql
-- Description  : Comando SELECT para verificar SQL executado por uma sessão
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_sql_executed.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT A.SQL_TEXT
FROM V$SQLTEXT A, V$SESSION B
WHERE A.ADDRESS = B.SQL_ADDRESS
      AND A.HASH_VALUE = B.SQL_HASH_VALUE
      AND B.SID = &sid
ORDER BY PIECE;
