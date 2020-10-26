-- -----------------------------------------------------------------------------------
-- File Name    : job_status_01.sql
-- Description  : Verificar SID e Usuários de JOBS que estão sendo processados na base 
--                de dados
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_status_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SELECT sid, r.job, log_user, r.this_date, r.this_sec
  FROM dba_jobs_running r,
       dba_jobs j
  WHERE r.job = j.job
  ORDER BY 1;
