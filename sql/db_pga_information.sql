-- -----------------------------------------------------------------------------------
-- File Name    : db_pga_information.sql
-- Description  : Script to check how much each session is getting in the PGA
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_pga_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000
col username for a20
col module for a40
col program for a40
SELECT NVL(a.username,'(oracle)') AS username, a.module, a.program, Trunc(b.value/1024) AS mory_kb
FROM v$session a, v$sesstat b, v$statname c
WHERE a.sid = b.sid AND b.statistic# = c.statistic# 
   AND c.name = 'session pga memory' 
   AND a.program IS NOT NULL
ORDER BY b.value DESC;
