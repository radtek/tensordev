-- -----------------------------------------------------------------------------------
-- File Name    : db_sql_executed.sql
-- Description  : See sql code for Tuning Pack
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sql_executed.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
set pages 1000
col SQL_ID format a15
col SQL_TEXT for a100
select SQL_ID, ELAPSED_TIME, ROWS_PROCESSED, SQL_TEXT from v$sql where SQL_TEXT like '% SELECT%';

