-- -----------------------------------------------------------------------------------
-- File Name    : db_rollback_information.sql
-- Description  : Displays rollback segment statistics
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_rollback_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT b.name "Segment Name",
       Trunc(c.bytes/1024) "Size (Kb)",
       a.optsize "Optimal",
       a.shrinks "Shrinks",
       a.aveshrink "Avg Shrink",
       a.wraps "Wraps",
       a.extends "Extends"
FROM   v$rollstat a,
       v$rollname b,
       dba_segments c
WHERE  a.usn  = b.usn
AND    b.name = c.segment_name
ORDER BY b.name;

SET PAGESIZE 14
SET VERIFY ON
