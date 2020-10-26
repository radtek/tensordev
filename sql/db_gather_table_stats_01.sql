-- -----------------------------------------------------------------------------------
-- File Name    : db_gather_table_stats_01.sql
-- Description  : Script to gather statistics for all tables of a specific owner
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_gather_table_stats_01.sql
-- Last Modified: 11/09/2015
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000

UNDEFINE OWNER

SELECT 'EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => '''||OWNER||''', TABNAME => '''||TABLE_NAME||''', ESTIMATE_PERCENT => 100, CASCADE => TRUE, DEGREE => 8, METHOD_OPT => ''FOR ALL INDEXED COLUMNS SIZE AUTO'');'
FROM dba_tables
WHERE owner = '&&owner'
ORDER BY OWNER;
