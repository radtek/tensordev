-- -----------------------------------------------------------------------------------
-- File Name    : dg_redo_transport.sql
-- Description  : Query the physical standby database to monitor Redo Apply and redo 
--                transport services activity at the standby site.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dg_redo_transport
-- Last Modified: 31/07/2014
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000

SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS 
FROM GV$MANAGED_STANDBY
ORDER BY SEQUENCE#, THREAD#
/
