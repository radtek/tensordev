-- -----------------------------------------------------------------------------------
-- File Name    : db_features_information.sql
-- Description  : Displays information about used database features.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_features_information.sql
-- Last Modified: 10/03/2015
-- -----------------------------------------------------------------------------------

PROMPT
PROMPT This script displays information about used database features
PROMPT To update the results with the most recent information
PROMPT rum DBMS_FEATURE_USAGE_INTERNAL as SYS
PROMPT Eg: EXEC DBMS_FEATURE_USAGE_INTERNAL.EXEC_DB_USAGE_SAMPLING(SYSDATE);
PROMPT

SELECT NAME, 
       DETECTED_USAGES, 
	   CURRENTLY_USED, 
	   to_char(FIRST_USAGE_DATE, 'DD/MM/YYYY HH24:MM'), 
	   to_char(LAST_USAGE_DATE, 'DD/MM/YYYY HH24:MM') 
FROM DBA_FEATURE_USAGE_STATISTICS 
ORDER BY NAME;
