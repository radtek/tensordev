-- -----------------------------------------------------------------------------------
-- File Name    : process_active.sql
-- Description  : Verica os processos que estao ativos no banco de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_active.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set linesize 180
set pagesize 5000
col OWNER_BD format a10
col USUARIO format a8
col SID format 9999999
col P_ORACLE format 9999999
col STATUS format a8
col PID_UNIX format a12
col SERVIDOR format a15
col LOGON format a16
col PROCESSO_SO format a25
col MODULO format a14
col PGA_USED_MEM format 999999999
col PGA_ALLOC_MEM format 999999999
col PGA_MAX_MEM format 999999999

select SUBSTR(s.USERNAME,1,10) Owner_BD,
       substr (OSUSER,1,8) usuario, 
	   s.SID SID,
       s.SERIAL# p_oracle,
	   status,
       SPID pid_unix, 
	   substr (machine,1,15) servidor,
       to_char(logon_time,'DD/MM/YYYY hh24:mi') logon,
       SUBSTR(s.program,1,25) processo_SO, 
	   SUBSTR(module,1,14) modulo,
	   pga_used_mem, 
	   pga_alloc_mem, 
	   pga_max_mem
from v$session s, 
     v$process p
where s.PADDR = p.ADDR
  and status = 'ACTIVE'
 order by 8
/
