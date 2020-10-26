-- -----------------------------------------------------------------------------------
-- File Name    : db_registry_information.sql
-- Description  : Displays information about database registry
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_registry_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 200
set pages 10000
col comp_id format a10
col comp_name format a50
col version format a20
col status format a20
select comp_id,comp_name,version,status from dba_registry order by 1;
