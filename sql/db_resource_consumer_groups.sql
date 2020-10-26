-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_consumer_groups.sql
-- Description  : Lists all consumer groups.
-- Call Syntax  : @db_resource_consumer_groups
-- Requirements : Access to the DBA views.
-- Last Modified: 02/10/2018
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

COLUMN STATUS FORMAT A10
COLUMN COMMENTS FORMAT A50

SELECT CONSUMER_GROUP,
       STATUS,
       COMMENTS
FROM DBA_RSRC_CONSUMER_GROUPS
ORDER BY CONSUMER_GROUP;
