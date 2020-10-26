-- -----------------------------------------------------------------------------------
-- File Name    : db_redo.sql
-- Description  : Displays information about database redo logfiles
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_redo.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINES 180 PAGES 5000 COLSEP |

COL GROUP# FOR 999999
COL THREAD# FOR 99999999
COL MBYTES FOR 99999999
COL MEMBERS FOR 99999999 
COL MEMBER FORMAT A66
COL FIRST_CHANGE# FORMAT 999999999999999
COL NEXT_CHANGE#  FORMAT 999999999999999
COL STATUS FORMAT A10

SELECT A.GROUP#, A.THREAD#, A.BYTES/1024/1024 AS MBYTES, A.MEMBERS, A.SEQUENCE#, A.FIRST_CHANGE#, A.NEXT_CHANGE#, A.STATUS, B.MEMBER
FROM V$LOG A, V$LOGFILE B
WHERE A.GROUP# = B.GROUP#
ORDER BY A.GROUP#, B.MEMBER;
