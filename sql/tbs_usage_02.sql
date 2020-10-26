-- -----------------------------------------------------------------------------------
-- File Name    : tbs_usage_02.sql
-- Description  : Displays information about tablespaces space with autoextend.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_usage_02.sql
-- Last Modified: 27/02/2013
-- -----------------------------------------------------------------------------------
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';

SET LINES 180 PAGES 5000 COLSEP |

PROMPT
PROMPT Displays information (descending) about tablespaces space consumption (query considering datafiles in autoextend mode)
PROMPT

COL TABLESPACE_NAME FOR A30
COL "CUR MB"        FOR "999G999G999D00"
COL "MAX MB"        FOR "999G999G999D00"
COL "TOTAL USED MB" FOR "999G999G999D00"
COL "TOTAL MB FREE" FOR "999G999G999D00"
COL "% USED"        FOR 999

SELECT DISTINCT a.tablespace_name,
            round(sum(a.bytes)/1024/1024,2) "CUR MB",
            round((sum(a.bytes)/1024/1024 - round(c.free/1024/1024)),2) "TOTAL USED MB",
            round(sum(decode(b.maxextend, null, a.bytes/1024/1024, b.maxextend*(SELECT value FROM v$parameter WHERE name='db_block_size')/1024/1024)),2) "MAX MB",
            round((sum(decode(b.maxextend, null, a.bytes/1024/1024, b.maxextend*(SELECT value FROM v$parameter WHERE name='db_block_size')/1024/1024)) - (sum(a.bytes)/1024/1024 - round(c.Free/1024/1024))),2) "TOTAL MB FREE", 
            round(100*(sum(a.bytes)/1024/1024 - round(c.free/1024/1024))/(sum(decode(b.maxextend, null, a.bytes/1024/1024, b.maxextend*(SELECT value FROM v$parameter WHERE name='db_block_size')/1024/1024)))) "% USED"
FROM dba_data_files a,
   sys.filext$ b,
   (SELECT d.tablespace_name , sum(nvl(c.bytes,0)) free
     FROM dba_tablespaces d,dba_free_space c
     WHERE d.tablespace_name = c.tablespace_name(+) 
     GROUP BY d.tablespace_name) c
WHERE a.file_id = b.file#(+)
    AND a.tablespace_name = c.tablespace_name  
--    AND a.tablespace_name = 'MGMT_AD4J_TS'
GROUP BY a.tablespace_name,
       c.free/1024
ORDER BY 6 DESC
/
