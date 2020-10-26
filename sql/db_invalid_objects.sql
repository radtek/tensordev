-- -----------------------------------------------------------------------------------
-- File Name    : db_invalid_objects.sql
-- Description  : Displays Database invalid objects
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_invalid_objects.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000
col object_name for a40
select owner, object_name, object_type, status
from dba_objects
where status = 'INVALID'
order by owner, object_type;
