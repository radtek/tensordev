-- -----------------------------------------------------------------------------------
-- File Name    : tbs_status.sql
-- Description  : This script shows the status of all tablespaces
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tbs_status.sql
-- Last Modified: 03/04/2012
-- -----------------------------------------------------------------------------------
col tablespace_name for a30
select TABLESPACE_NAME, BLOCK_SIZE, MIN_EXTENTS, MAX_EXTENTS, STATUS
from dba_tablespaces
order by tablespace_name;
