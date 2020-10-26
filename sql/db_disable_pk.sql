-- -----------------------------------------------------------------------------------
-- File Name    : db_disable_pk.sql
-- Description  : Desabilitando PKs
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_disable_pk.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET FEEDBACK OFF
SET VERIFY OFF
SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE PRIMARY KEY;'
FROM all_constraints a
WHERE a.constraint_type = 'P'
   AND a.owner=Upper('&2') 
   AND a.table_name=DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'));

SPOOL OFF
SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON
