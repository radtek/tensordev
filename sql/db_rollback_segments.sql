-- -----------------------------------------------------------------------------------
-- File Name    : db_rollback_segments.sql
-- Description  : Reports rollback statistic information including name, shrinks,
--                wraps, size and optimal size. This script is enabled to work   
--                with Oracle parallel server.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_rollback_segments.sql
-- Last Modified: 10/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Rollback Segments                                           |
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

COLUMN instance_name  FORMAT a9               HEADING 'Instance'
COLUMN rollback_name  FORMAT a30              HEADING 'Rollback Name'
COLUMN tablespace     FORMAT a11              HEADING 'Tablspace'
COLUMN in_extents     FORMAT a23              HEADING 'Init / Next Extents'
COLUMN m_extents      FORMAT a23              HEADING 'Min / Max Extents'
COLUMN status         FORMAT a8               HEADING 'Status'
COLUMN wraps          FORMAT 99,999           HEADING 'Wraps' 
COLUMN shrinks        FORMAT 99,999           HEADING 'Shrinks'
COLUMN opt            FORMAT 999,999,999,999  HEADING 'Opt. Size'
COLUMN bytes          FORMAT 999,999,999,999  HEADING 'Bytes'
COLUMN extents        FORMAT 999              HEADING 'Extents'

BREAK ON instance_name SKIP 2

COMPUTE SUM LABEL 'Total: ' OF bytes ON instance_name

SELECT
    i.instance_name                           instance_name
  , a.owner || '.' || a.segment_name          rollback_name
  , a.tablespace_name                         tablespace
  , TRIM(TO_CHAR(a.initial_extent, '999,999,999,999')) || ' / ' ||
    TRIM(TO_CHAR(a.next_extent, '999,999,999,999'))                    in_extents
  , TRIM(TO_CHAR(a.min_extents, '999,999,999,999'))    || ' / ' ||
    TRIM(TO_CHAR(a.max_extents, '999,999,999,999'))                    m_extents
  , a.status                                  status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
    gv$instance       i
  , gv$rollstat       d
  , sys.undo$         c
  , dba_rollback_segs a
  , dba_segments      b
WHERE
      i.inst_id      = d.inst_id
  AND d.usn          = c.us#
  AND a.segment_name = c.name
  AND a.segment_name = b.segment_name
ORDER BY
    i.instance_name
  , a.segment_name;
  