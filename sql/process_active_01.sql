-- -----------------------------------------------------------------------------------
-- File Name    : process_active_01.sql
-- Description  : Verica os processos que estao ativos no banco de dados com um 
--                determinado PID do SO
-- Requirements : Access to the DBA views.
-- Call Syntax  : @process_active_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINE 120
SET PAGESIZE 1000
COL SQL_TEXT FORMAT A120
SELECT t1.spid AS "Processo O/S", t2.SID, 
         t2.serial#, t2.program AS "Programa",
                    t2.username AS "Usuario do DB", t2.osuser AS "Usuario do O/S",
                    TO_CHAR (t2.logon_time,
                               'DD/MM/YYYY HH24:MI:SS'
                               ) AS "Data/Hora Login",
                     ROUND (t2.last_call_et / 60, 2) AS time_last_call,
                     SYSDATE - (1 / 24 / 60 / 60 * last_call_et) last_call_time,
                     t2.machine AS "Machine",
                     t3.sql_text
FROM v$process t1, v$session t2, v$sql t3
WHERE t1.addr = t2.paddr
AND t2.sql_address = t3.address
AND t1.spid = &PIDSO;
