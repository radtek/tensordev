-- -----------------------------------------------------------------------------------
-- File Name    : db_up_information.sql
-- Description  : Displays information about database startup time.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_up_information.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
set lines 180 pages 5000 colsep |
col host_name format a20
col instance_name format a13
col db_unique_name format a14
col status format a16
col database_status format a20
col started format a20
select host_name, instance_name, name as DB_NAME, db_unique_name, status, database_status, open_mode, to_char(startup_time, 'DD/MM/YYYY hh24:mm:ss') as STARTED 
from v$instance, v$database;
