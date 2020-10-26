-- -----------------------------------------------------------------------------------
-- File Name    : 12c_cdb_resource_plan_directives.sql
-- Description  : Displays CDB resource plan directives.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @12c_cdb_resource_plan_directives
-- Last Modified: 02/10/2018
-- -----------------------------------------------------------------------------------

COLUMN PLAN FORMAT A30
COLUMN PLUGGABLE_DATABASE FORMAT A25
SET LINESIZE 100 VERIFY OFF

SELECT PLAN, 
       PLUGGABLE_DATABASE, 
       SHARES, 
       UTILIZATION_LIMIT AS UTIL,
       PARALLEL_SERVER_LIMIT AS PARALLEL
FROM   DBA_CDB_RSRC_PLAN_DIRECTIVES
WHERE  PLAN = DECODE(UPPER('&1'), 'ALL', PLAN, UPPER('&1'))
ORDER BY PLAN, PLUGGABLE_DATABASE;

SET VERIFY ON
