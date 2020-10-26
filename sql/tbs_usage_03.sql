-- -----------------------------------------------------------------------------------
-- File Name    : tbs_usage_03.sql
-- Description  : Displays information about tablespaces that are over 90% used.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_usage_03.sql
-- Last Modified: 09/03/2015
-- -----------------------------------------------------------------------------------

PROMPT
PROMPT Displays information (descending) about space usage of the tablespaces
PROMPT that are over 90% used (query considering datafiles in autoextend mode)
PROMPT

COL "CUR MB" FOR 999,999,999.00
COL "MAX MB" FOR 999,999,999.00
COL "TOTAL USED" FOR 999,999,999.00
COL "TOTAL MB FREE" FOR 999,999,999.00
COL "% USED" FOR 999

SELECT * 
FROM (
      SELECT DISTINCT a.tablespace_name,
                  round(sum(a.bytes)/1024/1024,2) "CUR MB",
                  round(sum(decode(b.maxextend, null, a.bytes/1024/1024, b.maxextend*(SELECT value FROM v$parameter WHERE name='db_block_size')/1024/1024)),2) "MAX MB",
                  round((sum(a.bytes)/1024/1024 - round(c.free/1024/1024)),2) "TOTAL USED",
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
		  AND a.tablespace_name NOT LIKE '%UNDO%'
      GROUP BY a.tablespace_name,
             c.free/1024
      ORDER BY 6 DESC
     )
WHERE "% USED" > 89
/
