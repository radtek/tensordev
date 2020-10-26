-- -----------------------------------------------------------------------------------
-- File Name    : tbs_temp_usage_01.sql
-- Description  : Verificação completa de espaço em tablespaces teporárias.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_temp_usage_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
[size="2"]SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY off
COLUMN tablespace_name FORMAT a18 HEAD 'Tablespace Name'
COLUMN tablespace_status FORMAT a9 HEAD 'Status'
COLUMN tablespace_size FORMAT 999,999,999,999 HEAD 'Size'
COLUMN used FORMAT 999,999,999,999 HEAD 'Used'
COLUMN used_pct FORMAT 999 HEAD 'Pct. Used'
COLUMN current_users FORMAT 9,999 HEAD 'Current Users'
BREAK ON report
COMPUTE SUM OF tablespace_size ON report
COMPUTE SUM OF used ON report
COMPUTE SUM OF current_users ON report

SELECT D.TABLESPACE_NAME TABLESPACE_NAME,
       D.STATUS TABLESPACE_STATUS,
       NVL(A.BYTES, 0) TABLESPACE_SIZE,
       NVL(T.BYTES, 0) USED,
       TRUNC(NVL(T.BYTES / A.BYTES * 100, 0)) USED_PCT,
       NVL(S.CURRENT_USERS, 0) CURRENT_USERS
  FROM SYS.DBA_TABLESPACES D,
       (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES
          FROM DBA_TEMP_FILES
         GROUP BY TABLESPACE_NAME) A,
       (SELECT TABLESPACE_NAME, SUM(BYTES_CACHED) BYTES
          FROM V$TEMP_EXTENT_POOL
         GROUP BY TABLESPACE_NAME) T,
       V$SORT_SEGMENT S
 WHERE D.TABLESPACE_NAME = A.TABLESPACE_NAME(+)
   AND D.TABLESPACE_NAME = T.TABLESPACE_NAME(+)
   AND D.TABLESPACE_NAME = S.TABLESPACE_NAME(+)
   AND D.EXTENT_MANAGEMENT LIKE 'LOCAL'
   AND D.CONTENTS LIKE 'TEMPORARY';

