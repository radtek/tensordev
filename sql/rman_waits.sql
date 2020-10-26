-- -----------------------------------------------------------------------------------
-- File Name    : rman_waits.sql
-- Description  : RMAN Waits
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_waits.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 120
column sid format 9999
column spid format 99999
column client_info format a25
column event format a30
column secs format 9999
SELECT SID, SPID, CLIENT_INFO, event, seconds_in_wait secs, p1, p2, p3
  FROM V$PROCESS p, V$SESSION s
  WHERE p.ADDR = s.PADDR
  and CLIENT_INFO like 'rman channel=%'
/
