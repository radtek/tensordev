-- -----------------------------------------------------------------------------------
-- File Name    : archives_generated_last_30_days.sql
-- Description  : Arquives gerados nos ultimos 30 dias
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archives_generated_last_30_days.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINES 180 PAGES 5000 COLSEP |

SELECT INSTANCE_NAME "DB", 
       TRUNC(AVG("TOTAL MB")) "AVG/H (MB)",
	   TRUNC(MAX("TOTAL MB")) "MAX/H (MB)"
FROM V$INSTANCE,
    (SELECT TO_CHAR(COMPLETION_TIME, 'YYYY-MM-DD HH24'), SUM(BLOCKS*BLOCK_SIZE)/1024/1024 "TOTAL MB" 
	 FROM V$ARCHIVED_LOG WHERE COMPLETION_TIME > SYSDATE - 30
     GROUP BY TO_CHAR(COMPLETION_TIME, 'YYYY-MM-DD HH24')
    )
GROUP BY INSTANCE_NAME
/
