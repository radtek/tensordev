-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_sessions_high_io.sql
-- Description  : Script to analyze Disk IO's
-- Requirements : Access to the DBA views
-- Call Syntax  : @db_perf_check_sessions_high_io.sql
-- Last Modified: 07/07/2016
-- -----------------------------------------------------------------------------------
prompt
prompt SESSIONS PERFORMING HIGH I/O > 50000
prompt

select s.username, p.spid, s.sid,s.process cli_process, s.status,t.disk_reads, s.last_call_et/3600 last_call_et_Hrs, s.action, s.program, lpad(t.sql_text,30) "Last SQL"
from v$session s, v$sqlarea t,v$process p
where s.sql_address =t.address 
  and s.sql_hash_value =t.hash_value 
  and p.addr=s.paddr 
  and t.disk_reads > 10000
order by t.disk_reads desc;
