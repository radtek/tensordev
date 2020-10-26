-- -----------------------------------------------------------------------------------
-- File Name    : db_tables_per_datafiles.sql
-- Description  : This script would be useful to findout how tables are spread across
--                different datafiles. 
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_tables_per_datafiles.sql
-- Last Modified: 14/08/2012
-- -----------------------------------------------------------------------------------
set lines 180 pages 10000

col OWNER format a20
col TABLE_NAME format a20
col FILE_NAME format a80

SELECT T.OWNER, T.TABLE_NAME, F.FILE_NAME
FROM DBA_TABLES T
INNER JOIN DBA_DATA_FILES F
       ON  T.TABLESPACE_NAME = F.TABLESPACE_NAME
WHERE T.OWNER = '&OWNER'
  AND T.TABLE_NAME = '&TABLE_NAME'
/
