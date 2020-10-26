-- -----------------------------------------------------------------------------------
-- File Name    : tbs_usage.sql
-- Description  : Displays information about tablespaces space.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_usage.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
prompt Para listar todas as tablespaces, digite ALL ou especifique uma tablespace

SET LINES 180 PAGES 5000 COLSEP |

UNDEFINE TABLESPACE

COLUMN TABLESPACE_NAME FORMAT A30 
COLUMN FREE_MB FORMAT 9999999.99 
COLUMN TAM_MB FORMAT 9999999.99 
COLUMN PCT_FREE FORMAT 999.99 

SELECT DF.TABLESPACE_NAME,FSS.FREE_MB/1024/1024 FREE_MB,SUM(DF.BYTES)/1024/1024 TAM_MB,FSS.FREE_MB/SUM(DF.BYTES)*100 PCT_FREE 
   FROM DBA_DATA_FILES DF, 
        (SELECT TABLESPACE_NAME, SUM(BYTES) FREE_MB 
         FROM DBA_FREE_SPACE 
         GROUP BY TABLESPACE_NAME 
         UNION 
        (SELECT TABLESPACE_NAME, (SELECT 0 FROM DUAL) FROM DBA_TABLESPACES 
         MINUS 
         SELECT DISTINCT TABLESPACE_NAME, (SELECT 0 FROM DUAL) FROM DBA_FREE_SPACE))FSS 
   WHERE DF.TABLESPACE_NAME = FSS.TABLESPACE_NAME 
     AND DF.TABLESPACE_NAME = DECODE('&&TABLESPACE', 'ALL', DF.TABLESPACE_NAME, '&TABLESPACE')
GROUP BY DF.TABLESPACE_NAME,FSS.FREE_MB 
ORDER BY 4 DESC;
