-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_plans.sql
-- Description  : Displays all resource plans from a database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_resource_plans.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

COLUMN status FORMAT A10
COLUMN comments FORMAT A50

SELECT plan,
       status,
       comments
FROM   dba_rsrc_plans
ORDER BY plan;
