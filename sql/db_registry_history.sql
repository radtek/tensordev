-- -----------------------------------------------------------------------------------
-- File Name    : db_registry_history.sql
-- Description  : Displays information about database registry history
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_registry_history.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 200

col   ACTION_TIME     format a34
col   ACTION          format a20
col   NAMESPACE       format a20
col   VERSION         format a12
col   COMMENTS        format a20
col   BUNDLE_SERIES   format a20
col   COMMENTS        format a40

select * from dba_registry_history order by 1;
