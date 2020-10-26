-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_plan_consumer_groups.sql
-- Description  : Lists all consumer groups from a resource manager plan
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_resource_plan_consumer_groups.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

COLUMN status FORMAT A10
COLUMN comments FORMAT A50

SELECT consumer_group,
       status,
       comments
FROM   dba_rsrc_consumer_groups
ORDER BY consumer_group;
