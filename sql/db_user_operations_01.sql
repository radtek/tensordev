-- -----------------------------------------------------------------------------------
-- File Name    : db_user_operations_01.sql
-- Description  : Displays the user and the text of the statement the user is executing
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_user_operations_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT OSUSER, SERIAL#, SQL_TEXT
FROM V$SESSION, V$SQL
WHERE V$SESSION.SQL_ADDRESS = V$SQL.ADDRESS
   AND V$SESSION.STATUS = 'ACTIVE';
