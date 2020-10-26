-- -----------------------------------------------------------------------------------
-- File Name    : tbs_usage_04.sql
-- Description  : Displays information about tablespaces space with autoextend,
--                including temporary tablespaces.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_usage_04.sql
-- Last Modified: 08/06/2015
-- -----------------------------------------------------------------------------------
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';

PROMPT
PROMPT Displays complete information (descending) about tablespaces consumption (query considering datafiles in autoextend mode)
PROMPT

SET LINES 180 PAGES 5000 COLSEP |

COL KTABLESPACE   FOR A30            HEADING 'Tablespace Name'
COL KTBS_SIZE     FOR "999G999G990"  HEADING 'Actual|Size MB'        JUSTIFY RIGHT
COL KTBS_EM_USO   FOR "999G999G990"  HEADING 'Real Used|Size MB'     JUSTIFY RIGHT
COL KTBS_MAXSIZE  FOR "999G999G990"  HEADING 'Maximum|Size MB'       JUSTIFY RIGHT
COL KFREE_SPACE   FOR "999G999G990"  HEADING 'Actual Free|Space MB'  JUSTIFY RIGHT
COL KSPACE        FOR "999G999G990"  HEADING 'Total Free|Space MB'   JUSTIFY RIGHT
COL KPERC         FOR 990            HEADING '%|Used'                JUSTIFY RIGHT

BREAK ON REPORT

COMPUTE SUM LABEL TOTAL: OF KTBS_SIZE    ON REPORT
COMPUTE SUM              OF KTBS_EM_USO  ON REPORT
COMPUTE SUM              OF KTBS_MAXSIZE ON REPORT
COMPUTE SUM              OF KFREE_SPACE  ON REPORT
COMPUTE SUM              OF KSPACE       ON REPORT

SELECT T.TABLESPACE_NAME KTABLESPACE,
       SUBSTR(T.CONTENTS, 1, 1) TIPO,
       TRUNC(D.TBS_SIZE/1024/1024) KTBS_SIZE,
       TRUNC((D.TBS_SIZE-NVL(S.FREE_SPACE, 0))/1024/1024) KTBS_EM_USO,
       TRUNC(D.TBS_MAXSIZE/1024/1024) KTBS_MAXSIZE,
       TRUNC(NVL(S.FREE_SPACE, 0)/1024/1024) KFREE_SPACE,
       TRUNC((D.TBS_MAXSIZE - D.TBS_SIZE + NVL(S.FREE_SPACE, 0))/1024/1024) KSPACE,
       DECODE(D.TBS_MAXSIZE, 0, 0, TRUNC((D.TBS_SIZE-NVL(S.FREE_SPACE, 0))*100/D.TBS_MAXSIZE)) KPERC
FROM
  ( SELECT SUM(BYTES) TBS_SIZE,
           SUM(DECODE(SIGN(MAXBYTES - BYTES), -1, BYTES, MAXBYTES)) TBS_MAXSIZE,
           TABLESPACE_NAME TABLESPACE
    FROM ( SELECT NVL(BYTES, 0) BYTES, NVL(MAXBYTES, 0) MAXBYTES, TABLESPACE_NAME
           FROM DBA_DATA_FILES
           UNION ALL
           SELECT NVL(BYTES, 0) BYTES, NVL(MAXBYTES, 0) MAXBYTES, TABLESPACE_NAME
           FROM DBA_TEMP_FILES
         )
    GROUP BY TABLESPACE_NAME
  ) D,
  ( SELECT SUM(BYTES) FREE_SPACE,
           TABLESPACE_NAME TABLESPACE
    FROM DBA_FREE_SPACE
    GROUP BY TABLESPACE_NAME
  ) S,
  DBA_TABLESPACES T
WHERE T.TABLESPACE_NAME = D.TABLESPACE(+) AND
      T.TABLESPACE_NAME = S.TABLESPACE(+)
ORDER BY 8 DESC;
