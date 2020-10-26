-- -----------------------------------------------------------------------------------
-- File Name    : db_basic_checklist.sql
-- Description  : Verifying instance status
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_basic_checklist.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 200
col host_name format a20
col instance_name format a20
col status format a20
col database_status format a20
col started format a20
select host_name,
       instance_name,
       status,
       database_status,
       to_char(startup_time, 'DD/MM/YYYY hh24:mm:ss') as STARTED
  from v$instance;
select count(*), status from dba_tablespaces group by status;
select distinct (status) from v$datafile;
select count(*) from v$recover_file;
select * from v$recovery_log;
select distinct (status) from v$controlfile;

