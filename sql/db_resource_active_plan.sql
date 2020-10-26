-- -----------------------------------------------------------------------------------
-- File Name    : db_resource_active_plan.sql
-- Description  : Lists the currently active resource plan if one is set.
-- Call Syntax  : @db_resource_active_plan
-- Requirements : Access to the v$ views.
-- Last Modified: 02/10/2018
-- -----------------------------------------------------------------------------------

SELECT NAME, IS_TOP_PLAN
FROM   V$RSRC_PLAN
ORDER BY NAME;
