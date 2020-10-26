-- -----------------------------------------------------------------------------------
-- File Name    : rman_throughput.sql
-- Description  : RMAN channels throughput and % completion
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_throughput
-- Last Modified: 29/08/2019
-- -----------------------------------------------------------------------------------

set linesize 126
column Pct_Complete format 99.99
column client_info format a25
column sid format 99999
column MB_PER_S format 999.99

SELECT s.client_info,
       l.sid,
       l.serial#,
       l.sofar,
       l.totalwork,
       round (l.sofar / l.totalwork*100,2) "Pct_Complete",
       aio.MB_PER_S,
       aio.LONG_WAIT_PCT
FROM v$session_longops l,
     v$session s,
    (select sid,
            serial,
            100* sum (long_waits) / sum (io_count) as "LONG_WAIT_PCT",
            sum (effective_bytes_per_second)/1024/1024 as "MB_PER_S"
     from v$backup_async_io
     group by sid, serial) aio
WHERE aio.sid = s.sid
  and aio.serial = s.serial#
  and l.opname like 'RMAN%'
  and l.opname not like '%aggregate%'
  and l.totalwork != 0
  and l.sofar <> l.totalwork
  and s.sid = l.sid
  and s.serial# = l.serial#
ORDER BY 1;
