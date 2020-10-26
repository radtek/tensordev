-- -----------------------------------------------------------------------------------
-- File Name    : db_controlfiles.sql
-- Description  : Displays informations about all the database controlfiles
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_controlfiles.sql
-- Last Modified: 04/04/2012
-- -----------------------------------------------------------------------------------
set lines 180
col name for a60
col is_recovery_dest_file format a10
select name, status, is_recovery_dest_file RECO
from v$controlfile;
