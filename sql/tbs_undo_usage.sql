-- -----------------------------------------------------------------------------------
-- File Name    : tbs_undo_usage.sql
-- Description  : Verificação completa de espaço em tablespaces de UNDO.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_undo_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
COL TABLESPACE_NAME FOR A30
SELECT SIZE_ALLOCATED.TABLESPACE_NAME,
       SIZE_ALLOCATED.SIZE_ALLOCATED_MB,
       SIZE_USED.SIZE_USED_MB,
       ROUND(SIZE_USED.SIZE_USED_MB / SIZE_ALLOCATED.SIZE_ALLOCATED_MB * 100,
             2) PCT_SIZE_USED_MB
  FROM (SELECT DUE.TABLESPACE_NAME,
               SUM(DUE.BYTES) / 1024 / 1024 AS SIZE_USED_MB
          FROM DBA_UNDO_EXTENTS DUE
         GROUP BY DUE.TABLESPACE_NAME) SIZE_USED,
       (SELECT DT.TABLESPACE_NAME,
               SUM(DDF.BYTES) / 1024 / 1024 SIZE_ALLOCATED_MB
          FROM DBA_TABLESPACES DT, DBA_DATA_FILES DDF
         WHERE DT.TABLESPACE_NAME = DDF.TABLESPACE_NAME
           AND DT.CONTENTS = 'UNDO'
         GROUP BY DT.TABLESPACE_NAME) SIZE_ALLOCATED
 WHERE SIZE_ALLOCATED.TABLESPACE_NAME = SIZE_USED.TABLESPACE_NAME(+)
 ORDER BY TABLESPACE_NAME;

