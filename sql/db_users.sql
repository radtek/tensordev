-- -----------------------------------------------------------------------------------
-- File Name    : db_users.sql
-- Description  : Displays information about all database users
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_users.sql
-- Last Modified: 31/05/2012
-- -----------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT Type the USERNAME or type ALL to list all users in the database
PROMPT
PROMPT

UNDEFINE USERNAME

SET LINES 180
SET PAGES 10000
SET COLSEP |

COL USERNAME             FOR A30
COL ACCOUNT_STATUS       FOR A30
COL PROFILE              FOR A30
COL CREATED              FOR A10
COL DEFAULT_TABLESPACE   FOR A30
COL TEMPORARY_TABLESPACE FOR A30

SELECT USERNAME, ACCOUNT_STATUS, TO_CHAR(CREATED, 'DD/MM/YYYY') CREATED, PROFILE, DEFAULT_TABLESPACE TBS_DEFAULT, TEMPORARY_TABLESPACE TEMP_TBS
FROM DBA_USERS
--WHERE CREATED > SYSDATE - 730
WHERE USERNAME LIKE UPPER(DECODE('&&USERNAME', 'ALL', USERNAME, 'all', USERNAME, '%&USERNAME%'))
ORDER BY USERNAME
/
