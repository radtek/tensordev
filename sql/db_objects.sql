-- -----------------------------------------------------------------------------------
-- File Name    : db_objects.sql
-- Description  : Show database objects
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_objects.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000
col owner for a20
col object_name for a40
select owner, object_name, object_type, status 
from dba_objects 
where owner = '&&owner'
order by owner, object_type;
