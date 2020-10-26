-- -----------------------------------------------------------------------------------
-- File Name    : db_parameters.sql
-- Description  : Displays all instance parameters
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_parameters.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60

SELECT p.name,
       p.type,
       p.value,
       p.isses_modifiable,
       p.issys_modifiable,
       p.isinstance_modifiable
FROM   v$parameter p
ORDER BY p.name;
