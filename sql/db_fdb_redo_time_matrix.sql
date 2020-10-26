-- -----------------------------------------------------------------------------------
-- File Name    : db_fdb_redo_time_matrix.sql
-- Description  : Provide details on the amount of redo data being collected by
--                Oracle Flashback Database over given time frames.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_fdb_redo_time_matrix.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance
FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Flashback Database Redo Time Matrix                         |
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

COLUMN begin_time               FORMAT a21                HEADING 'Begin Time'
COLUMN end_time                 FORMAT a21                HEADING 'End Time'
COLUMN flashback_data           FORMAT 9,999,999,999,999  HEADING 'Flashback Data'
COLUMN db_data                  FORMAT 9,999,999,999,999  HEADING 'DB Data'
COLUMN redo_data                FORMAT 9,999,999,999,999  HEADING 'Redo Data'
COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated|Flashback Size'

SELECT
    TO_CHAR(begin_time, 'DD-MON-YYYY HH24:MI:SS') begin_time
  , TO_CHAR(end_time, 'DD-MON-YYYY HH24:MI:SS') end_time
  , flashback_data
  , db_data
  , redo_data
  , estimated_flashback_size
FROM
    v$flashback_database_stat
ORDER BY
   begin_time;
