-- -----------------------------------------------------------------------------------
-- File Name    : rac_session_information.sql
-- Description  : Displays information on all database sessions for whole RAC
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_session_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 180
SET PAGESIZE 10000

COLUMN username FORMAT A15
COLUMN inst format 9999
COLUMN osuser format a10
COLUMN sid format 9999
COLUMN serial format 99999
COLUMN spid format a8
COLUMN module format a20
COLUMN machine FOR A25
COLUMN program for a35
COLUMN logon_time FORMAT A20

SELECT NVL(s.username, '(oracle)') AS username,
       s.inst_id as inst, 
       s.osuser as osuser,
       s.sid as sid,
       s.serial# as serial,
       p.spid as spid,
       s.status,
       s.module,
       s.machine,
       s.program,
       TO_CHAR(s.logon_Time,'DD/MM/YYYY HH24:MI') AS logon_time
FROM   gv$session s,
       gv$process p
WHERE  s.paddr   = p.addr
AND    s.inst_id = p.inst_id
ORDER BY s.inst_id, s.logon_time desc
/
