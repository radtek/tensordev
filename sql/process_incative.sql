-- -----------------------------------------------------------------------------------
-- File Name    : process_incative.sql
-- Description  : Verifica os processos inativos no banco de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_incative.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set linesize 250
set pagesize 5000
col Owner_BD for a25 
select s.USERNAME Owner_BD,
     substr (OSUSER,1,8) usuario, s.SID SID,
         s.SERIAL# p_oracle ,status,
     SPID pid_unix, substr (machine,1,15) servidor,
     to_char(logon_time,'yy/mm/dd hh24:mi') logon,
     SUBSTR(s.program,1,25) processo_SO, SUBSTR(module,1,14) modulo
     ,pga_used_mem, pga_alloc_mem, pga_max_mem
  from v$session s, v$process p
  where s.PADDR = p.ADDR
  and status = 'INACTIVE'
 order by 8;
