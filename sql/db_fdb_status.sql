-- -----------------------------------------------------------------------------------
-- File Name    : db_fdb_status.sql
-- Description  : Provide an overview of the current state of the Flashback Database
--                feature. First check that Flashback Database is enabled. Next,
--                provide an overview of the retention policy settings and estimated 
--                size of the Flashback Logs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_fdb_status.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance
FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Flashback Database Status                                   |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN dbid                                HEADING 'DB ID'
COLUMN name             FORMAT a15         HEADING 'DB Name'
COLUMN log_mode         FORMAT a18         HEADING 'Log Mode'
COLUMN flashback_on     FORMAT a18         HEADING 'Flashback DB On?'

SELECT
    dbid
  , name
  , log_mode
  , flashback_on
FROM v$database;

COLUMN oldest_flashback_scn                               HEADING 'Oldest|Flashback SCN'
COLUMN oldest_flashback_time    FORMAT a21                HEADING 'Oldest|Flashback Time' JUST right
COLUMN retention_target         FORMAT 999,999            HEADING 'Retention|Target (min)'
COLUMN flashback_size           FORMAT 9,999,999,999,999  HEADING 'Flashback|Size'
COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated|Flashback Size'

SELECT
    oldest_flashback_scn
  , TO_CHAR(oldest_flashback_time, 'DD-MON-YYYY HH24:MI:SS') oldest_flashback_time
  , retention_target
  , flashback_size
  , estimated_flashback_size
FROM v$flashback_database_log;
