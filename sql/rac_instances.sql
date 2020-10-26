-- -----------------------------------------------------------------------------------
-- File Name    : rac_instances.sql
-- Description  : Provide a summary report of all configured instances for the current 
--                clustered database.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_instances.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance
FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Oracle RAC Instances                                        |
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

COLUMN instance_name          FORMAT a13         HEAD 'Instance|Name / Number'
COLUMN thread#                FORMAT 99999999    HEAD 'Thread #'
COLUMN host_name              FORMAT a30         HEAD 'Host|Name'
COLUMN status                 FORMAT a6          HEAD 'Status'
COLUMN startup_time           FORMAT a20         HEAD 'Startup|Time'
COLUMN database_status        FORMAT a8          HEAD 'Database|Status'
COLUMN archiver               FORMAT a8          HEAD 'Archiver'
COLUMN logins                 FORMAT a10         HEAD 'Logins?'
COLUMN shutdown_pending       FORMAT a8          HEAD 'Shutdown|Pending?'
COLUMN active_state           FORMAT a6          HEAD 'Active|State'
COLUMN version                                   HEAD 'Version'

SELECT
    instance_name || ' (' || instance_number || ')' instance_name
  , thread#
  , host_name
  , status
  , TO_CHAR(startup_time, 'DD-MON-YYYY HH:MI:SS') startup_time
  , database_status
  , archiver
  , logins
  , shutdown_pending
  , active_state
  , version
FROM
    gv$instance
ORDER BY
    instance_number;
	