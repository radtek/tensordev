-- -----------------------------------------------------------------------------------
-- File Name    : rac_sessions_active.sql
-- Description  : Displays information on all active database sessions for the whole RAC
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_sessions_active.sql
-- Last Modified: 07/10/2014
-- -----------------------------------------------------------------------------------
SET LINESIZE 180
SET PAGESIZE 10000
SET COLSEP |

COLUMN username FORMAT A16
COLUMN inst format 9999
COLUMN osuser format a10
COLUMN sid format 9999
COLUMN serial format 99999
COLUMN spid format a8
COLUMN module format a20
COLUMN machine format A30
COLUMN program format a30
COLUMN logon_time FORMAT A18

SELECT NVL(s.username, '(oracle)') AS username,
       s.inst_id as inst, 
       s.osuser as osuser,
       s.sid as sid,
       s.serial# as serial,
       p.spid as spid,
       s.status,
       substr(s.module,1,20) module,
       substr(s.machine,1,30) machine,
       substr(s.program,1,30) program,
       TO_CHAR(s.logon_Time,'DD/MM/YYYY HH24:MI') AS logon_time,
	   s.sql_id
FROM   gv$session s,
       gv$process p
WHERE  s.paddr   = p.addr
AND    s.inst_id = p.inst_id
AND    s.status = 'ACTIVE'
AND    s.username <> '(oracle)'
--AND    s.username = 'T6821470'
ORDER BY s.inst_id, s.logon_time desc
/
