-- -----------------------------------------------------------------------------------
-- File Name    : tbs_undo_usage_01.sql
-- Description  : Verificação completa de espaço em tablespaces de UNDO.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_undo_usage_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT TO_CHAR(BEGIN_TIME, 'YYYY-MM-DD HH24:MI:SS') STARTTIME,
       TO_CHAR(END_TIME, 'YYYY-MM-DD HH24:MI:SS') ENDTIME,
       UNDOBLKS, MAXQUERYLEN MAXQRYLEN
FROM V$UNDOSTAT;
