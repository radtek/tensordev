-- -----------------------------------------------------------------------------------
-- File Name    : db_sec_users.sql
-- Description  : Lists all users in the database including their default and 
--                temporary tablespaces.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sec_users.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Security - All Users                                        |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN username              FORMAT a30    HEAD 'Username'
COLUMN account_status        FORMAT a17    HEAD 'Status'
COLUMN expiry_date                         HEAD 'Expire Date'
COLUMN default_tablespace    FORMAT a28    HEAD 'Default Tablespace'
COLUMN temporary_tablespace  FORMAT a15    HEAD 'Temp Tablespace'
COLUMN created                             HEAD 'Created On'
COLUMN profile               FORMAT a10    HEAD 'Profile'
COLUMN sysdba                FORMAT a6     HEAD 'SYSDBA'
COLUMN sysoper               FORMAT a7     HEAD 'SYSOPER'

SELECT distinct
    a.username                                        username
  , a.account_status                                  account_status
  , TO_CHAR(a.expiry_date, 'mm/dd/yyyy HH24:MI:SS')   expiry_date
  , a.default_tablespace                              default_tablespace
  , a.temporary_tablespace                            temporary_tablespace
  , TO_CHAR(a.created, 'mm/dd/yyyy HH24:MI:SS')       created
  , a.profile                                         profile
  , DECODE(p.sysdba,'TRUE', 'TRUE','')                sysdba
  , DECODE(p.sysoper,'TRUE','TRUE','')                sysoper
FROM
    dba_users       a
  , v$pwfile_users  p
WHERE
    p.username (+) = a.username 
ORDER BY username
/
