-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_db_block_buffer_usage.sql
-- Description  : Report on the state of all DB_BLOCK_BUFFERS. This script must be run 
--                as the SYS user.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dbperf_db_block_buffer_usage.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 135
SET PAGESIZE 9999
SET VERIFY   off

COLUMN block_status      HEADING "Block Status"
COLUMN count             HEADING "Count"

SELECT
    DECODE(state, 0, 'Free',
                  1, DECODE(lrba_seq, 0, 'Available', 'Being Modified'),
                  2, 'Not Modified',
                  3, 'Being Read',
                     'Other') block_status
  , count(*) count
FROM
  sys.x$bh
GROUP BY
    DECODE(state, 0, 'Free',
                  1, DECODE(lrba_seq, 0, 'Available', 'Being Modified'),
                  2, 'Not Modified',
                  3, 'Being Read',
                     'Other')
/
