-- -----------------------------------------------------------------------------------
-- File Name    : db_objects_in_library_cache.sql
-- Description  : Displays information about objects in the library cache
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_objects_in_library_cache.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT SUBSTR(owner,1,10) Owner,
       SUBSTR(type,1,12)  Type,
       SUBSTR(name,1,20)  Name,
       executions,
       sharable_mem       Mem_used,
       SUBSTR(kept||' ',1,4)   "Kept?"
 FROM v$db_object_cache WHERE TYPE IN ('TRIGGER','PROCEDURE','PACKAGE BODY','PACKAGE')
 ORDER BY EXECUTIONS DESC;
