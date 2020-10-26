-- -----------------------------------------------------------------------------------
-- File Name    : job_status.sql
-- Description  : Verifying jobs status
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_status.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
SELECT JOB,SUBSTR(WHAT,1,35),FAILURES,PRIV_USER, NEXT_DATE, NEXT_SEC, BROKEN FROM DBA_JOBS;
