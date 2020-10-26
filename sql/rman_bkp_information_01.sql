-- -----------------------------------------------------------------------------------
-- File Name    : rman_bkp_information_01.sql
-- Description  : Shows information about backup pieces according to the backups
--                informed in the query rman_bkp_information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_bkp_information_01.sql
-- Last Modified: 18/07/2014
-- -----------------------------------------------------------------------------------

set lines 220
set pages 1000
set colsep |

col backup_type for a4 heading "TYPE"
col controlfile_included heading "CF?"
col incremental_level heading "INCR LVL"
col pieces for 999 heading "PCS"
col elapsed_seconds heading "ELAPSED|SECONDS"
col device_type for a10 trunc heading "DEVICE|TYPE"
col compressed for a4 heading "ZIP?"
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col input_file_scan_only for a4 heading "SCAN|ONLY"

select
  d.bs_key, 
  d.backup_type, 
  d.controlfile_included, 
  d.incremental_level, 
  d.pieces,
  to_char(d.start_time, 'dd/mm/yyyy hh24:mi:ss') start_time,
  to_char(d.completion_time, 'dd/mm/yyyy hh24:mi:ss') completion_time,
  d.elapsed_seconds, 
  d.device_type, 
  d.compressed, 
  (d.output_bytes/1024/1024) output_mbytes, 
  s.input_file_scan_only,
  d.status
from V$BACKUP_SET_DETAILS d
  join V$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
where session_recid = &SESSION_RECID
  and session_stamp = &SESSION_STAMP
order by d.start_time;
