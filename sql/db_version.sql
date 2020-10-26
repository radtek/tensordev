-- -----------------------------------------------------------------------------------
-- File Name    : db_version.sql
-- Description  : Displays information about database version.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_version.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180 colsep | pages 5000
col INFORMACOES for a80
select 'DATABASE = ' || name as INFORMACOES from v$database
union all
select banner from v$version
/
