-- -----------------------------------------------------------------------------------
-- File Name    : 12c_cdb_resource_plans.sql
-- Description  : Displays CDB resource plans.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @12c_cdb_resource_plans
-- Last Modified: 02/10/2018
-- -----------------------------------------------------------------------------------

COLUMN PLAN FORMAT A30
COLUMN COMMENTS FORMAT A30
COLUMN STATUS FORMAT A10

SET LINESIZE 180 PAGES 5000 COLSEP |

SELECT PLAN_ID,
       PLAN,
       COMMENTS,
       STATUS,
       MANDATORY
FROM   DBA_CDB_RSRC_PLANS
ORDER BY PLAN;

--teste