-- -----------------------------------------------------------------------------------
-- File Name    : rman_sessions.sql
-- Description  : Simple script for monitoring the RMAN sessions in the db
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_sessions.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select sid, serial#, context, sofar, totalwork, round(sofar/totalwork*100,2) "%_complete"
from v$session_longops 
where opname like 'RMAN%' 
   and opname not like '%aggregate%' 
   and totalwork != 0 
   and sofar <> totalwork;
