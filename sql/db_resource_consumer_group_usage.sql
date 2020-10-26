-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_consumer_group_usage.sql
-- Description  : Lists usage information of consumer groups.
-- Call Syntax  : @db_resource_consumer_group_usage
-- Requirements : Access to the v$ views.
-- Last Modified: 12/11/2004
-- -----------------------------------------------------------------------------------

SELECT NAME, CONSUMED_CPU_TIME
FROM V$RSRC_CONSUMER_GROUP
ORDER BY NAME;
