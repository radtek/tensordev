-- -----------------------------------------------------------------------------------
-- File Name    : db_sec_roles.sql
-- Description  : Report on all roles defined in the database and which users are 
--                assigned to that role.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_sec_roles.sql
-- Last Modified: 09/04/2012
-- -----------------------------------------------------------------------------------
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Security - All Roles                                        |
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

COLUMN role             FORMAT a30    HEAD 'Role Name'
COLUMN grantee          FORMAT a30    HEAD 'Grantee'
COLUMN admin_option     FORMAT a15    HEAD 'Admin Option?'
COLUMN default_role     FORMAT a15    HEAD 'Default Role?'

BREAK ON role SKIP 2

SELECT
    b.role
  , a.grantee
  , a.admin_option
  , a.default_role
FROM
    dba_role_privs  a
  , dba_roles       b
WHERE
    granted_role(+) = b.role
ORDER BY
    b.role
  , a.grantee
/
