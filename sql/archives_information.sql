-- -----------------------------------------------------------------------------------
-- File Name    : archives_information.sql
-- Description  : Arquives gerados por dia até agora
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archives_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------

PROMPT
PROMPT ESTA QUERY RELACIONA A QTDE E VOLUMETRIA DE ARCHIVES GERADOS NOS ULTIMOS DIAS
PROMPT

SELECT   SUM_ARCH.DAY "Date",
         SUM_ARCH.GENERATED_MB "Total MB Generated",
         SUM_ARCH_DEL.DELETED_MB "Total MB Deleted",
--       SUM_ARCH.GENERATED_MB - SUM_ARCH_DEL.DELETED_MB "REMAINING_MB",
		 TOTAL.TOTAL "Total Archives Generated"
    FROM (  SELECT TO_CHAR (FIRST_TIME, 'DD/MM/YYYY') DAY,
                   SUM (ROUND ( (blocks * block_size) / (1024 * 1024), 0))
                      GENERATED_MB
              FROM V$ARCHIVED_LOG
             WHERE ARCHIVED = 'YES'
            GROUP BY TO_CHAR (FIRST_TIME, 'DD/MM/YYYY')) SUM_ARCH,
         (  SELECT TO_CHAR (FIRST_TIME, 'DD/MM/YYYY') DAY,
                   SUM (ROUND ( (blocks * block_size) / (1024 * 1024), 0))
                      DELETED_MB
              FROM V$ARCHIVED_LOG
             WHERE ARCHIVED = 'YES' AND DELETED = 'YES'
            GROUP BY TO_CHAR (FIRST_TIME, 'DD/MM/YYYY')) SUM_ARCH_DEL,
		 (  SELECT TO_CHAR(FIRST_TIME, 'DD/MM/YYYY') DATA, 
		           COUNT(*) TOTAL 
			  FROM V$LOGHIST 
			GROUP BY TO_CHAR(FIRST_TIME, 'DD/MM/YYYY')) TOTAL
   WHERE SUM_ARCH.DAY = SUM_ARCH_DEL.DAY(+)
     AND TOTAL.DATA = SUM_ARCH.DAY
   GROUP BY SUM_ARCH.DAY, SUM_ARCH.GENERATED_MB, SUM_ARCH_DEL.DELETED_MB, TOTAL.TOTAL
ORDER BY TO_DATE (SUM_ARCH.DAY, 'DD/MM/YYYY');
