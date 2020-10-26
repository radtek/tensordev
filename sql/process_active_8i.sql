-- -----------------------------------------------------------------------------------
-- File Name    : process_active_8i.sql
-- Description  : Verica os processos que estao ativos no banco de dados 8i 
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_active_8i.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20
SELECT NVL(s.username, '(oracle)') AS username,
       s.osuser,
       s.sid,
       s.serial#,
       s.status,
       p.spid,	
       TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session s,
       v$process p
WHERE  s.paddr  = p.addr
AND    s.status = 'ACTIVE' -- (ACTIVE / INACTIVE)
-- AND    s.sid = 397
-- AND    s.username = 'FISCAL'
-- AND    s.osuser = 'synchroimp' 
-- AND    p.spid = 2318412
ORDER BY s.username, s.osuser;
