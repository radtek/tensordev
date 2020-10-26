-- -----------------------------------------------------------------------------------
-- File Name    : db_gather_table_stats_02.sql
-- Description  : This script gather a specific type of statistics. For example, it 
--                could be used to gather TABLE, INDEX, SCHEMA or DATABASE statistics
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_gather_table_stats_02.sql
-- Last Modified: 11/09/2015
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000

PROMPT
PROMPT This script gather a specific type of statistics. For example, it could be used to gather TABLE, INDEX, SCHEMA, DATABASE or DICTIONARY statistics
PROMPT If collecting SCHEMA statistics, type "NULL" for the value OBJECT_NAME
PROMPT If collecting DATABASE statistics, type "NULL" for the values OWNER and OBJECT_NAME
PROMPT If collecting DICTIONARY statistics, type "NULL" for the values OWNER and OBJECT_NAME
PROMPT

DECLARE
	L_TYPE 		VARCHAR2(30) := UPPER('&TYPE');
	L_OWNER 	VARCHAR2(30) := UPPER('&OWNER');
	L_OBJECT	VARCHAR2(30) := UPPER('&OBJECT_NAME');
	L_DEGREE	NUMBER := '&DEGREE';
	L_SAMPLE	NUMBER := '&SAMPLE';
BEGIN
	IF L_TYPE = 'TABLE' THEN 
		DBMS_STATS.GATHER_TABLE_STATS(L_OWNER, L_OBJECT, DEGREE => L_DEGREE, ESTIMATE_PERCENT => L_SAMPLE, CASCADE => TRUE);
	ELSIF L_TYPE = 'INDEX' THEN 
		DBMS_STATS.GATHER_INDEX_STATS(L_OWNER, L_OBJECT, DEGREE => L_DEGREE, ESTIMATE_PERCENT => L_SAMPLE);
	ELSIF L_TYPE = 'SCHEMA' THEN 
		DBMS_STATS.GATHER_SCHEMA_STATS(L_OWNER, DEGREE => L_DEGREE, ESTIMATE_PERCENT => L_SAMPLE, CASCADE => TRUE);
	ELSIF L_TYPE = 'DATABASE' THEN 
		DBMS_STATS.GATHER_DATABASE_STATS(DEGREE => L_DEGREE, ESTIMATE_PERCENT => L_SAMPLE, CASCADE => TRUE);
	ELSIF L_TYPE = 'DICTIONARY' THEN 
		DBMS_STATS.GATHER_DICTIONARY_STATS(DEGREE => L_DEGREE, ESTIMATE_PERCENT => L_SAMPLE, CASCADE => TRUE);
	END IF;
END;
/
