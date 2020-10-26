-- -----------------------------------------------------------------------------------
-- File Name    : db_locks_03.sql
-- Description  : Verifying database locked objects
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_locks_03
-- Last Modified: 18/09/2012
-- -----------------------------------------------------------------------------------
col owner for a20
col osuser for a20
col object_name for a20
col object_type for a20
col status for a10
col machine for a40

select
   c.owner,
   b.osuser,
   c.object_name,
   c.object_type,
   b.sid,
   b.serial#,
   b.status,
   b.sql_id,
   b.machine
from
   v$locked_object a ,
   v$session b,
   dba_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id;
