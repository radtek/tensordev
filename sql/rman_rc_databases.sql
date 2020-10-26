-- -----------------------------------------------------------------------------------
-- File Name    : rman_rc_databases.sql
-- Description  : Provide a listing of all databases found in the RMAN recovery 
--                catalog
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rman_rc_databases.sql
-- Last Modified: 03/04/2012
-- -----------------------------------------------------------------------------------

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN db_key                 FORMAT 999999                 HEADING 'DB|Key'
COLUMN dbinc_key              FORMAT 999999                 HEADING 'DB Inc|Key'
COLUMN dbid                                                 HEADING 'DBID'
COLUMN name                   FORMAT a12                    HEADING 'Database|Name'
COLUMN resetlogs_change_num                                 HEADING 'Resetlogs|Change Num'
COLUMN resetlogs              FORMAT a21                    HEADING 'Reset Logs|Date/Time'

prompt
prompt Listing of all databases in the RMAN recovery catalog
prompt 

SELECT
    rd.db_key
  , rd.dbinc_key
  , rd.dbid
  , rd.name
  , rd.resetlogs_change#                                 resetlogs_change_num
  , TO_CHAR(rd.resetlogs_time, 'DD-MON-YYYY HH24:MI:SS') resetlogs
FROM
    rc_database   rd
ORDER BY
    rd.name
/
