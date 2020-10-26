-- -----------------------------------------------------------------------------------
-- File Name    : db_get_ddl_tables_02.sql
-- Description  : Displays DDL definition for existing users' tables and indexes. 
--                Set the schema name in the query and run the statement
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_get_ddl_tables_02.sql
-- Last Modified: 01/11/2017
-- -----------------------------------------------------------------------------------

SET LINES 200
SET LONG 9999999
SET HEAD OFF
SET ECHO OFF
SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF

SELECT DBMS_METADATA.GET_DDL(OBJECT_TYPE, OBJECT_NAME, OWNER)||';'
FROM ( -- Convert DBA_OBJECTS.OBJECT_TYPE to DBMS_METADATA object type:
       SELECT OWNER,
              OBJECT_NAME,
              OBJECT_TYPE
       FROM DBA_OBJECTS 
       WHERE OWNER IN ('NETDBA') 
	     AND OBJECT_TYPE IN (SELECT DISTINCT(OBJECT_TYPE) 
		                     FROM DBA_OBJECTS 
							 WHERE OBJECT_TYPE IN ('TABLE','INDEX')
							 )
      )
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;

PROMPT
PROMPT
PROMPT
PROMPT This script listed all DDL for tables and indexes
PROMPT
