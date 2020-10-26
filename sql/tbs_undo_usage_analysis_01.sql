-- -----------------------------------------------------------------------------------
-- File Name    : tbs_undo_usage_analysis_01.sql
-- Description  : Query to identify optimal undo_retention parameter
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_undo_usage_analysis_01.sql
-- Last Modified: 15/09/2014
-- -----------------------------------------------------------------------------------

COL "UNDO RETENTION [SEC]" FORMAT A22

SELECT D.UNDO_SIZE / (1024 * 1024) "ACTUAL UNDO SIZE [MBYTE]",
       SUBSTR(E.VALUE, 1, 25) "UNDO RETENTION [SEC]",
       ROUND((D.UNDO_SIZE / (TO_NUMBER(F.VALUE) * G.UNDO_BLOCK_PER_SEC))) "OPTIMAL UNDO RETENTION [SEC]"
  FROM (SELECT SUM(A.BYTES) UNDO_SIZE
          FROM V$DATAFILE A, V$TABLESPACE B, DBA_TABLESPACES C
         WHERE C.CONTENTS = 'UNDO'
           AND C.STATUS = 'ONLINE'
           AND B.NAME = C.TABLESPACE_NAME
           AND A.TS# = B.TS#) D,
       V$PARAMETER E,
       V$PARAMETER F,
       (SELECT MAX(UNDOBLKS / ((END_TIME - BEGIN_TIME) * 3600 * 24)) UNDO_BLOCK_PER_SEC
          FROM V$UNDOSTAT) G
 WHERE E.NAME = 'undo_retention'
   AND F.NAME = 'db_block_size' 
   
/
