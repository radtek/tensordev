-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_file_waits.sql
-- Description  : Reports on Busy Buffer Waits per file.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_file_waits.sql
-- Last Modified: 10/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 145
SET PAGESIZE 9999

COLUMN filename  FORMAT a58           HEAD "File Name"
COLUMN file#     FORMAT 999           HEAD "File #"
COLUMN ct        FORMAT 999,999,999   HEAD "Waits (count)"
COLUMN time      FORMAT 999,999,999   HEAD "Time (cs)"
COLUMN avg       FORMAT 999.999       HEAD "Avg Time"


SELECT
    a.indx + 1  file#
  , b.name      filename
  , a.count     ct
  , a.time      time
  , a.time/(DECODE(a.count,0,1,a.count)) avg
FROM
    x$kcbfwait   a
  , v$datafile   b
WHERE
      indx < (SELECT count(*) FROM v$datafile)
  AND a.indx+1 = b.file#
ORDER BY a.time
/
