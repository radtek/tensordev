-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_vrfy.sql
-- Description  : Identifying jobs that are in wait state
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_vrfy.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
SET PAGESIZE 1000

column sid format 99999
column serial format 99999
column username format a15
column osuser format a15
column sql_id format a14
column event format a14
column program format a14
column machine format a14
column kill format a14

select a.sid,
	   a.SERIAL#, 
	   TRUNC(a.LAST_CALL_ET/60) TEMPO, 
	   a.USERNAME,
	   a.OSUSER,
	   a.BLOCKING_SESSION, 
	   a.SQL_ID, 
	   substr(a.EVENT,1,14) as event, 
	   substr(a.program,1,14) as program, 
	   substr(a.MACHINE,1,14) as machine,
	   a.STATUS, 
	   'kill -9 '||B.SPID as KILL
from V$SESSION a inner join V$PROCESS B on B.ADDR=a.PADDR where a.USERNAME is not null and a.USERNAME not in ('DBSNMP','SYSMAN') and a.STATUS = 'ACTIVE' 
order by a.LAST_CALL_ET desc
/
