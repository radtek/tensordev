-- -----------------------------------------------------------------------------------
-- File Name    : tbs_temp_usage_02.sql
-- Description  : Verifica��o de espa�o em tablespaces tepor�rias com autoextend.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_temp_usage_02.sql
-- Last Modified: 12/05/2016
-- -----------------------------------------------------------------------------------

COL KTABLESPACE   FOR A22          HEADING 'TABLESPACE'
COL KTBS_SIZE     FOR 999,999,990  HEADING 'ACTUAL|SIZE MB'        JUSTIFY RIGHT
COL KTBS_EM_USO   FOR 999,999,990  HEADING 'USED MB'               JUSTIFY RIGHT
COL KTBS_MAXSIZE  FOR 999,999,990  HEADING 'MAXIMUM|SIZE MB'       JUSTIFY RIGHT
COL KFREE_SPACE   FOR 999,999,990  HEADING 'ACTUAL FREE|SPACE MB'  JUSTIFY RIGHT
COL KSPACE        FOR 999,999,990  HEADING 'TOTAL FREE|SPACE MB'   JUSTIFY RIGHT
COL KPERC         FOR 990          HEADING '%|USED'                JUSTIFY RIGHT

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
      T.TABLESPACE_NAME = S.TABLESPACE(+) AND
	  T.CONTENTS = 'TEMPORARY'
ORDER BY 8 DESC;