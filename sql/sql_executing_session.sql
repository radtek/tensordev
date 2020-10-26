-- -----------------------------------------------------------------------------------
-- File Name    : sql_executing_session.sql
-- Description  : Displays information about statements being executed for the sessions.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @sql_executing_session.sql
-- Last Modified: 14/02/2013
-- -----------------------------------------------------------------------------------
col module for a20
col sql_text for a40
col username for a10
SELECT 
 module, 
 sql_text, 
 username, 
-- disk_reads_per_exec, 
-- buffer_gets, 
-- disk_reads, 
-- parse_calls, 
-- sorts, 
 executions, 
 rows_processed, 
-- hit_ratio, 
 first_load_time, 
-- sharable_mem, 
-- persistent_mem, 
-- runtime_mem, 
 cpu_time, 
 elapsed_time, 
 address, 
 hash_value 
FROM 
  (SELECT
   module, 
   sql_text , 
   u.username , 
   round((s.disk_reads/decode(s.executions,0,1, s.executions)),2)  disk_reads_per_exec, 
   s.disk_reads , 
   s.buffer_gets , 
   s.parse_calls , 
   s.sorts , 
   s.executions , 
   s.rows_processed , 
   100 - round(100 *  s.disk_reads/greatest(s.buffer_gets,1),2) hit_ratio, 
   s.first_load_time , 
   sharable_mem , 
   persistent_mem , 
   runtime_mem, 
   cpu_time, 
   elapsed_time, 
   address, 
   hash_value 
  FROM
   sys.v_$sql s, 
   sys.all_users u 
  WHERE
   s.parsing_user_id=u.user_id 
   and UPPER(u.username) not in ('SYS','SYSTEM') 
  ORDER BY
   4 desc) 
WHERE
 rownum <= 20;
 