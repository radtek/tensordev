-- -----------------------------------------------------------------------------------
-- File Name    : db_objects_being_acessed.sql
-- Description  : Lists all objects being accessed in the schema
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_objects_being_acessed.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 255
SET VERIFY OFF

COLUMN object FORMAT A30

SELECT a.object,
       a.type,
       a.sid,
       b.username,
       b.osuser,
       b.program
FROM   v$access a,
       v$session b
WHERE  a.sid   = b.sid
AND    a.owner = UPPER('&1')
ORDER BY a.object;
