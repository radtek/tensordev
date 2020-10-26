-- -----------------------------------------------------------------------------------
-- File Name    : db_perf_check_session_waits_07.sql
-- Description  : Identifying sessions that are in wait state
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_perf_check_session_waits_07.sql
-- Last Modified: 08/04/2012
-- -----------------------------------------------------------------------------------

column wait_class format a30
column NAME format a70
column time_secs format 9999999999
column pct format 99999

SELECT wait_class, NAME, ROUND (time_secs, 2) time_secs, ROUND (time_secs * 100 / SUM (time_secs) OVER (), 2) pct 
FROM (SELECT n.wait_class, e.event NAME, e.time_waited / 100 time_secs
      FROM v$system_event e, v$event_name n
      WHERE n.NAME = e.event 
	    AND n.wait_class <> 'Idle'
        AND time_waited > 0
	  UNION
	  SELECT 'CPU', 'server CPU', SUM (VALUE / 1000000) time_secs
      FROM v$sys_time_model
      WHERE stat_name IN ('background cpu time', 'DB CPU'))
ORDER BY
time_secs DESC;
