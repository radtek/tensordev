-- -----------------------------------------------------------------------------------
-- File Name    : rac_session_waits.sql
-- Description  : Displays information on all database session waits for the whole RAC
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rac_session_waits.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET COLSEP |

column inst_id format 9999
column sid format 9999
column serial format 99999
column tempo format 9999
column username format a10
column osuser format a10
column blocking_session format 99999
column sql_id format a14
column event format a30
column program format a25
column machine format a25
column kill format a14

select a.inst_id, 
       a.sid,
	   a.SERIAL#, 
	   TRUNC(a.LAST_CALL_ET/60) TEMPO, 
	   a.USERNAME,
	   a.OSUSER,
--	   a.BLOCKING_SESSION blocking, 
	   a.SQL_ID, 
	   substr(a.EVENT,1,30) as event, 
	   substr(a.program,1,25) as program, 
	   substr(a.MACHINE,1,25) as machine,
	   a.STATUS, 
	   'kill -9 '||B.SPID as KILL
from GV$SESSION a inner join GV$PROCESS B on B.ADDR=a.PADDR where a.USERNAME is not null and a.USERNAME not in ('DBSNMP','SYSMAN') and a.STATUS = 'ACTIVE' 
order by a.inst_id, a.LAST_CALL_ET desc
/
