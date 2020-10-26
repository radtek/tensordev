-- -----------------------------------------------------------------------------------
-- File Name    : dg_information.sql
-- Description  : Dataguard general information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dg_information
-- Last Modified: 31/07/2014
-- -----------------------------------------------------------------------------------
set lines 180
set pages 10000
column ROLE format a7 tru 

select name, database_role, log_mode, controlfile_type, protection_mode, protection_level, switchover_status, dataguard_broker as BROKER
from v$database; 
