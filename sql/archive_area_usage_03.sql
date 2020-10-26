-- -----------------------------------------------------------------------------------
-- File Name    : archive_area_usage_03.sql
-- Description  : It shows information about Flashback options and space usage
-- Requirements : Access to the DBA views.
-- Call Syntax  : @archive_area_usage_03.sql
-- Last Modified: 07/07/2015
-- -----------------------------------------------------------------------------------

PROMPT
PROMPT HOW FAR BACK CAN WE FLASHBACK TO (TIME)?
PROMPT
SELECT TO_CHAR(OLDEST_FLASHBACK_TIME,'DD-MON-YYYY HH24:MI:SS') "OLDEST FLASHBACK TIME"
FROM V$FLASHBACK_DATABASE_LOG;

PROMPT
PROMPT HOW FAR BACK CAN WE FLASHBACK TO (SCN)?
PROMPT
COL OLDEST_FLASHBACK_SCN FORMAT 99999999999999999999999999
SELECT OLDEST_FLASHBACK_SCN FROM V$FLASHBACK_DATABASE_LOG;

PROMPT
PROMPT FLASHBACK AREA USAGE
SELECT * FROM   V$FLASH_RECOVERY_AREA_USAGE;

PROMPT
COL ROUND(SPACE_LIMIT/1048576) HEADING "SPACE ALLOCATED (MB)" FORMAT 999999
COL ROUND(SPACE_USED/1048576) HEADING "SPACE USED (MB)" FORMAT 99999
COL NAME HEADING "FLASHBACK LOCATION" FORMAT A40
SELECT NAME, ROUND(SPACE_LIMIT/1048576),ROUND(SPACE_USED/1048576)
FROM  V$RECOVERY_FILE_DEST;

