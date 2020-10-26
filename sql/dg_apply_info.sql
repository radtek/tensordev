-- -----------------------------------------------------------------------------------
-- File Name    : dg_apply_info.sql
-- Description  : Dataguard log applying information. To be run on the standby database
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dg_apply_info
-- Last Modified: 31/07/2014
-- -----------------------------------------------------------------------------------

SELECT sequence#, thread#, first_time, next_time, APPLIED, DELETED FROM v$archived_log ORDER BY first_time;

SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "Last Sequence Received", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#) "Difference"
FROM (SELECT THREAD#, SEQUENCE# 
      FROM V$ARCHIVED_LOG 
	  WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#, MAX(FIRST_TIME) 
	                                  FROM V$ARCHIVED_LOG 
									  GROUP BY THREAD#)) ARCH,
     (SELECT THREAD# ,SEQUENCE# 
	  FROM V$LOG_HISTORY 
      WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#, MAX(FIRST_TIME) 
									  FROM V$LOG_HISTORY 
									  GROUP BY THREAD#)) APPL
WHERE ARCH.THREAD# = APPL.THREAD#
ORDER BY 1;
