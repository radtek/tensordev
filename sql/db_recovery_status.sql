-- -----------------------------------------------------------------------------------
-- File Name    : db_recovery_status.sql
-- Description  : Database recovery status information
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_recovery_status.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
select FILE#, ONLINE_STATUS, ERROR
from v$recover_file
order by FILE#;
