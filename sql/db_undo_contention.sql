-- -----------------------------------------------------------------------------------
-- File Name    : db_undo_contention.sql
-- Description  : Undo contention report.
-- Call Syntax  : @db_undo_contention.sql
-- Last Modified: 10/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Undo Contention                                             |
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

COLUMN instance_name      FORMAT a10    HEAD 'Instance'
COLUMN class              FORMAT a18    HEADING 'Class'    
COLUMN ratio                            HEADING 'Wait Ratio'       

BREAK ON instance_name SKIP 2

SELECT
    i.instance_name                     instance_name
  , w.class                             class
  , ROUND(100*(w.count/SUM(s.value)),8) ratio
FROM
    gv$instance i
  , gv$waitstat w
  , gv$sysstat s
WHERE
      i.inst_id = w.inst_id
  AND i.inst_id = s.inst_id
  AND w.class IN (  'system undo header'
                  , 'system undo block'
                  , 'undo header'
                  , 'undo block'
                 )
  AND s.name IN ('db block gets', 'consistent gets')
GROUP BY
    i.instance_name
  , w.class
  , w.count
ORDER BY
    i.instance_name
  , w.class;
  