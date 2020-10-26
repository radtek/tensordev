-- -----------------------------------------------------------------------------------
-- File Name    : xplan.sql
-- Description  : Displays queries explain plans.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @xplan.sql
-- Last Modified: 11/09/2015
-- -----------------------------------------------------------------------------------

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE',NULL,'ALL'));
