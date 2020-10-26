-- -----------------------------------------------------------------------------------
-- File Name    : db_system_parameters.sql
-- Description  : Displays a list of all the system parameters.
--                Comment out isinstance_modifiable for use prior to 10g.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_system_parameters.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60

SELECT sp.name,
       sp.type,
       sp.value,
       sp.isses_modifiable,
       sp.issys_modifiable,
       sp.isinstance_modifiable
FROM   v$system_parameter sp
ORDER BY sp.name;
