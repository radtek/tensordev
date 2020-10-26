-- -----------------------------------------------------------------------------------
-- File Name    : db_creation_info.sql
-- Description  : Displays information about tempfiles.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_creation_info.sql
-- Last Modified: 24/05/2012
-- -----------------------------------------------------------------------------------
col dbid format 99999999999
col name for a10
col db_unique_name for a14
col log_mode for a15
col open_mode for a10
col guard_status for a12
col flashback_on for a12
col version_time for a12
col created for a18
select dbid, name, db_unique_name, log_mode, to_char(created, 'DD/MM/YYYY  HH24:MM') CREATED, to_char(version_time, 'DD/MM/YYYY') VERSION_TIME, open_mode, guard_status, flashback_on
from v$database;
