-- -----------------------------------------------------------------------------------
-- File Name    : db_cache_advice.sql
-- Description  : Predicts how changes to the buffer cache will affect physical reads
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_cache_advice.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
COLUMN   SIZE_FOR_ESTIMATE           FORMAT 999,999,999,999   HEADING 'CACHE SIZE (MB)'
COLUMN   BUFFERS_FOR_ESTIMATE        FORMAT 999,999,999       HEADING 'BUFFERS'
COLUMN   ESTD_PHYSICAL_READ_FACTOR   FORMAT 999.90            HEADING 'ESTD PHYS|READ FACTOR'
COLUMN   ESTD_PHYSICAL_READS         FORMAT 999,999,999,999   HEADING 'ESTD PHYS| READS'

SELECT SIZE_FOR_ESTIMATE, 
       BUFFERS_FOR_ESTIMATE,
       ESTD_PHYSICAL_READ_FACTOR,
       ESTD_PHYSICAL_READS
FROM   V$DB_CACHE_ADVICE
WHERE  NAME = 'DEFAULT'
  AND  BLOCK_SIZE = (SELECT VALUE
                     FROM V$PARAMETER
                      WHERE  NAME = 'DB_BLOCK_SIZE')
  AND  ADVICE_STATUS = 'ON'
ORDER BY 1;
