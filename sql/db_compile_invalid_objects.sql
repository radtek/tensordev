-- -----------------------------------------------------------------------------------
-- File Name    : db_compile_invalid_objects.sql
-- Description  : Listing invalid objects in the db
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_compile_invalid_objects.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)||' '||owner||'.'||object_name||' compile '|| 
                 decode(object_type,'PACKAGE BODY','body','PACKAGE','BODY')||';' 
                 from dba_objects 
                 where status = 'INVALID'
                 order by owner;
